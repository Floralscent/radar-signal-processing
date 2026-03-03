# Radar Signal Processing and Systems (2023.07 - 2025.12)

본 저장소는 숭실대학교 NSPL(Neuro-Engineering and Neural Signal Processing Lab)에서 학부연구생으로 활동하며 수행한 레이더 시스템 설계 및 신호처리 알고리즘 연구 기록을 담고 있습니다.

## 활동 개요
* 소속: 숭실대학교 차세대 신호처리 연구실 (NSPL)
* 역할: 학부연구생
* 기간: 2023.07 ~ 2025.12
* 주요 분야: FMCW Radar System, Signal Processing, SAR Imaging, Beamforming

---

## 주요 프로젝트 (Main Projects)

### 1. 레이더 시스템 이해 및 생체 신호 처리 (Vital Sensing)
레이더의 기초 동작 원리를 학습하고, FMCW 레이더를 활용해 비접촉식으로 인체의 미세한 움직임을 측정하는 연구를 수행했습니다.

* 주요 내용: 
    * FMCW 레이더 시스템 파라미터 설계 및 분석
    * Phase Extraction 알고리즘을 활용한 실시간 호흡 및 움직임 측정
    * FFT 및 Bandpass Filter를 이용한 신호 정제

* 상세 보기: [./01_Vital_Sensing](./01_Vital_Sensing)

### 2. 신규 레이더 빔포밍 및 인간 타겟 SAR (Beamforming and Target)
안테나 배열을 활용한 빔포밍 기술을 습득하고, 이를 확장하여 동적인 인간 타겟을 영상화하는 기술을 연구했습니다.

* 주요 내용: 
    * DoA(Direction of Arrival) 추정 알고리즘 및 FOV(Field of View) 검증
    * 기초 빔포밍(Beamforming) 기반의 신호 이득 향상 기법 구현
    * 빔포밍 알고리즘을 확장한 인간 타겟 대상 SAR 영상화

* 상세 보기: [./02_Beamforming_Target](./02_Beamforming_Target)

### 3. Raw 데이터 기반 산업용 SAR 적용 (Industrial SAR)
이전 프로젝트에서 습득한 알고리즘을 실제 Raw 데이터에 적용하여 고해상도 영상을 복원하는 실습을 진행했습니다.

* 주요 내용: 
    * 고정 타겟(철판 등) 및 산업용 환경에서의 SAR 스캔 시나리오 구축
    * 수집된 PointCloud 데이터가 아닌 Raw 데이터의 신호 처리 및 영상 복원(Imaging)

* 상세 보기: [./03_Industrial_SAR](./03_Industrial_SAR)

---

## Tech Stack
* Languages: MATLAB, Python
* Algorithms: FFT, CFAR, DoA, Beamforming, SAR Imaging, Phase Unwrapping
* Tools: bitsensing radars(AF910, MOD 630, MOD 620)

---

## 주요 역량
* 알고리즘 구현: 신호 처리 파이프라인 전 과정을 직접 코드로 구현하며 상세 주석을 포함함
* 시스템 분석: 하드웨어 사양에 따른 시스템 성능 예측 및 변수 최적화 수행
* 데이터 시각화: 신호 데이터를 Range-Doppler Map, SAR Image 등으로 시각화하여 분석함

---