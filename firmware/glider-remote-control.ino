const int stepPitchPin = 4;
const int dirPitchPin = 5;
const int endStopPitchPin = 30;

const int stepRollPin = 6;
const int dirRollPin = 7;
const int endStopRollPin = 31;

const int stepEnginePin = 8;
const int dirEnginePin = 9;
const int endStopEnginePin = 32;

const int forwardDir = 0;
const int reverseDir = 1;

int pitchPos;
int pitchMax = 2800;
int pitchDelay = 900;
int rollPos;
int rollMax = 50;
int rollDelay = 3000;
int enginePos;
int engineMax = 1900;
int engineDelay = 1100;

void setup() {
  pinMode(stepRollPin, OUTPUT);
  pinMode(dirRollPin, OUTPUT);

  pinMode(stepPitchPin, OUTPUT);
  pinMode(dirPitchPin, OUTPUT);

  pinMode(stepEnginePin, OUTPUT);
  pinMode(dirEnginePin, OUTPUT);

  homeAll();

  Serial.begin(115200);

}

boolean reachedEndStop(int endStop) {
  return (digitalRead(endStop) == 0);
}

boolean dirForward(int dir) {
  return (dir == 0);
}

int runMotor(int stepPin, int dirPin, int endStop, int dir, int amountToMove, int currentPos, int maxPos, int motorDelay) {
  digitalWrite(dirPin, dir);
  for (int x = 0; x < amountToMove; x++) {
    if (dirForward(dir) && reachedEndStop(endStop) ) {
      return 0;
    }
    if (!dirForward(dir) && (currentPos + 1 > maxPos)) {
      break;
    }

    digitalWrite(stepPin, HIGH);
    delayMicroseconds(motorDelay);
    digitalWrite(stepPin, LOW);
    delayMicroseconds(motorDelay);

    if (dirForward(dir)) {
      currentPos += -1;
    } else {
      currentPos += 1;
    }
  }
  return currentPos;
}

void diagnosticOutput () {
  Serial.print("Roll end stop: ");
  Serial.print(digitalRead(endStopRollPin));
  Serial.print(", pitch end stop: ");
  Serial.print(digitalRead(endStopPitchPin));
  Serial.print(", engine end stop: ");
  Serial.print(digitalRead(endStopEnginePin));
  Serial.println();
  Serial.print("Roll pos: ");
  Serial.print(rollPos);
  Serial.print(", Pitch pos: ");
  Serial.print(pitchPos);
  Serial.print(", Engine pos: ");
  Serial.print(enginePos);
  Serial.println();

}

void homeAll () {
  // home, move the motors the maximum distance towards the endstop, if the actuator is closer than the far end the endstop will stop movement
  rollPos = runMotor(stepRollPin, dirRollPin, endStopRollPin, forwardDir, rollMax, rollPos, rollMax, rollDelay);
  pitchPos = runMotor(stepPitchPin, dirPitchPin, endStopPitchPin, forwardDir, pitchMax, pitchPos, pitchMax, pitchDelay);
  enginePos = runMotor(stepEnginePin, dirEnginePin, endStopEnginePin, forwardDir, engineMax, enginePos, engineMax, engineDelay);

}

void loop() {

  if (Serial.available() > 0) {

    int inByte = Serial.read();
    Serial.println(inByte);
    switch (inByte) {
      case 1:
        Serial.println("Disabled Rotating mass clockwise");
        rollPos = runMotor(stepRollPin, dirRollPin, endStopRollPin, reverseDir, 5, rollPos, rollMax, rollDelay);
        break;
      case 2:
        Serial.println("Disabled Rotating mass anticlockwise");
        rollPos = runMotor(stepRollPin, dirRollPin, endStopRollPin, forwardDir, 5, rollPos, rollMax, rollDelay);
        break;
      case 3:
        Serial.println("Mass forward");
        pitchPos = runMotor(stepPitchPin, dirPitchPin, endStopPitchPin, forwardDir, 900, pitchPos, pitchMax, pitchDelay);
        break;
      case 4:
        Serial.println("Mass backward");
        pitchPos = runMotor(stepPitchPin, dirPitchPin, endStopPitchPin, reverseDir, 900, pitchPos, pitchMax, pitchDelay);
        break;
      case 5:
        Serial.println("Plunger backward");
        enginePos = runMotor(stepEnginePin, dirEnginePin, endStopEnginePin, reverseDir, 100, enginePos, engineMax, engineDelay);
        break;
      case 6:
        Serial.println("Plunger forward");
        enginePos = runMotor(stepEnginePin, dirEnginePin, endStopEnginePin, forwardDir, 100, enginePos, engineMax, engineDelay);
        break;
      case 7:
        Serial.println("Homing");
        homeAll();
      default:
        Serial.println("None");

    }
    diagnosticOutput();
  }
}
