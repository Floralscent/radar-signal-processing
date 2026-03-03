# Vital Sensing: Breathing and Motion Detection

본 프로젝트는 FMCW 레이더를 활용하여 비접촉 방식으로 인체의 미세 변위(호흡) 및 동적 움직임을 측정하고 분석하는 연구입니다. 숭실대학교 NSPL 학부연구생 과정 중 수행되었습니다.

## 1. Breathing Detection (호흡 측정)

FMCW 레이더의 위상(Phase) 변화를 정밀하게 추적하여 흉부의 미세한 움직임을 추출하고, 이를 통해 실시간 호흡률을 산출합니다.

### 주요 알고리즘
* Phase Extraction: 타겟 빈(Bin)에서의 위상 변화 추출
* Phase Unwrapping: 위상 불연속성 제거를 통한 연속 변위 데이터 확보
* Bandpass Filtering: 호흡 주파수 대역(0.1Hz ~ 0.5Hz) 신호 정제

<table style="width: 100%; text-align: center;">
  <tr>
    <td style="width: 50%; border: none;">
      <img src="./01_Breathing/img/Experimental_setup.png" width="100%"/>
      <br/><sub>호흡 실험 환경</sub>
    </td>
    <td style="width: 50%; border: none;">
      <img src="./01_Breathing/img/radar_parameter.png" width="100%"/>
      <br/><sub>레이더 파라미터 설정</sub>
    </td>
  </tr>
</table>

<table style="width: 100%; text-align: center;">
  <tr>
    <td style="width: 25%; border: none;">
      <img src="./01_Breathing/img/Phase_Map.jpg" width="100%"/>
      <br/><sub>전체 페이즈 맵</sub>
    </td>
    <td style="width: 25%; border: none;">
      <img src="./01_Breathing/img/Range_Spectrogram.png" width="100%"/>
      <br/><sub>레인지 스펙트로그램</sub>
    </td>
    <td style="width: 25%; border: none;">
      <img src="./01_Breathing/img/Phase_of_Range_Bin32.jpg" width="100%"/>
      <br/><sub>타겟 위치(32번 Bin) 페이즈</sub>
    </td>
    <td style="width: 25%; border: none;">
      <img src="./01_Breathing/img/Respiration_Rate_Radar_Ground_Truth.jpg" width="100%"/>
      <br/><sub>최종 산출 호흡률(BPM)</sub>
    </td>
  </tr>
</table>
---

## 2. Motion Detection (움직임 측정)

타겟의 거리와 속도 변화를 실시간으로 탐지하여 움직임의 패턴과 강도를 분석합니다.

### 주요 알고리즘
* 2D FFT: 거리(Range) 및 속도(Doppler) 정보 동시 추출
* Static Clutter Removal: 고정 장애물 신호 제거를 통한 타겟 시인성 확보
* Peak Detection: 동적 타겟의 실시간 위치 추적

### 분석 데이터 및 시각화
* Range-Doppler Map: 타겟의 거리와 속도 분포 시각화
* Radar Parameters: 탐지 거리 및 속도 해상도 설정값
* Range-Spectrogram (1st/2nd FFT): 신호 처리 단계별 주파수 분석 결과
* Range-Velocity Map: 시간에 따른 타겟의 속도 변화 추적

<table style="width: 100%; text-align: center;">
  <tr>
    <td style="width: 20%; border: none;">
      <img src="./02_Motion_Detection/img/m1.png" width="100%"/>
      <br/><sub>도플러 맵</sub>
    </td>
    <td style="width: 20%; border: none;">
      <img src="./02_Motion_Detection/img/m2.png" width="100%"/>
      <br/><sub>레이더 파라미터</sub>
    </td>
    <td style="width: 20%; border: none;">
      <img src="./02_Motion_Detection/img/m3.png" width="100%"/>
      <br/><sub>1차 FFT 결과</sub>
    </td>
    <td style="width: 20%; border: none;">
      <img src="./02_Motion_Detection/img/m4.png" width="100%"/>
      <br/><sub>2차 FFT 결과</sub>
    </td>
    <td style="width: 20%; border: none;">
      <img src="./02_Motion_Detection/img/m5.png" width="100%"/>
      <br/><sub>레인지-벨로시티 맵</sub>
    </td>
  </tr>
</table>

---

