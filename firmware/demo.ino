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
int pitchMax = 2750;
int pitchDelay = 800;
int rollPos;
int rollMax = 205;
int rollDelay = 3500;
int enginePos;
int engineMax = 1900;
int engineDelay = 900;

void setup() {
  pinMode(stepRollPin, OUTPUT);
  pinMode(dirRollPin, OUTPUT);

  pinMode(stepPitchPin, OUTPUT);
  pinMode(dirPitchPin, OUTPUT);

  pinMode(stepEnginePin, OUTPUT);
  pinMode(dirEnginePin, OUTPUT);

  homeAll();
  diving();

  Serial.begin(115200);

}

boolean reachedEndStop(int endStop) {
  return (digitalRead(endStop) == 0);
}

boolean dirForward(int dir) {
  return (dir == 0);
}

int runMotor(int stepPin, int dirPin, int endStop, int targetPos, int currentPos, int maxPos, int motorDelay) {
  int amountToMove = currentPos - targetPos;
  //bw: 0 if forwards, 1 if backwards
  int bw = ((amountToMove / abs(amountToMove)) * 0.25 + 0.25) * 2;
  amountToMove = abs(amountToMove);
  digitalWrite(dirPin, 1 - bw);
  for (int x = 0; x < amountToMove; x++) {
    if (bw && reachedEndStop(endStop) ) {
      return 0;
    }
    if (!bw && (currentPos + 1 > maxPos)) {
      break;
    }

    digitalWrite(stepPin, HIGH);
    delayMicroseconds(motorDelay);
    digitalWrite(stepPin, LOW);
    delayMicroseconds(motorDelay);

    currentPos += (bw * 0.5 - 0.25) * -4;
  }
  return currentPos;
}

void homeAll () {
  // home, move the motors the maximum distance towards the endstop, if the actuator is closer than the far end the endstop will stop movement
  rollPos = runMotor(stepRollPin, dirRollPin, endStopRollPin, 0, rollMax, rollMax, rollDelay);
  pitchPos = runMotor(stepPitchPin, dirPitchPin, endStopPitchPin, 0, pitchMax, pitchMax, pitchDelay);
  enginePos = runMotor(stepEnginePin, dirEnginePin, endStopEnginePin, 0, engineMax, engineMax, engineDelay);
}

void diving () {
  rollPos = runMotor(stepRollPin, dirRollPin, endStopRollPin, rollMax * 0.5, rollPos, rollMax, rollDelay);
  pitchPos = runMotor(stepPitchPin, dirPitchPin, endStopPitchPin, pitchMax * 0.5, pitchPos, pitchMax, pitchDelay);
  enginePos = runMotor(stepEnginePin, dirEnginePin, endStopEnginePin, engineMax * 1, enginePos, engineMax, engineDelay);
  enginePos = runMotor(stepEnginePin, dirEnginePin, endStopEnginePin, engineMax * 0, enginePos, engineMax, engineDelay);
  while (true) {
    enginePos = runMotor(stepEnginePin, dirEnginePin, endStopEnginePin, 0, enginePos, engineMax, engineDelay);
    delay(3000);
    enginePos = runMotor(stepEnginePin, dirEnginePin, endStopEnginePin, engineMax * 1, enginePos, engineMax, engineDelay);
    delay(3000);
  }
}


void loop() {
}
