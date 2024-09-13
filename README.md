# 🚲 블루투스 라이딩 측정앱 RideThis

![playstore](https://github.com/user-attachments/assets/5ac2493c-40e3-4695-9ce0-bee2f82c1ac0)


<br>

## 1. 프로젝트 소개

- RideThis는 자전거에 부착된 케이던스 기기를 통해 라이딩 데이터를 실시간으로 기록하고, 다양한 통계 정보를 제공하는 플랫폼입니다.
- 라이딩 동안의 케이던스, 속도, 거리, 칼로리 데이터를 편리하게 확인할 수 있습니다.
- 특정 거리(Km)의 라이딩 기록을 서버에 등록하여, 친구나 전체 사용자들과 기록을 비교할 수 있습니다.

<br>

## 2. 개발 기간

- 개발 기간 : 2024-08-12 ~ 2024-08-30
- 오류 수정 및 리팩토링 기간: 2024-09-01 ~ 2024-09-08

<br>

## 3. 팀원 및 역할 분담

### 팀원 구성

<div align="center">

| **황규상** | **김성국** | **최광우** | **황승혜** |
| :------: |  :------: | :------: | :------: |
| [<img src="https://avatars.githubusercontent.com/u/51147673?v=4"/> <br/> @황규상](https://github.com/kyuSangHwang) | [<img src="https://avatars.githubusercontent.com/u/114292187?v=4"/> <br/> @김성국](https://github.com/SeongKookKIM) | [<img src="https://avatars.githubusercontent.com/u/78129823?v=4"/> <br/> @최광우](https://github.com/madcow95) | [<img src="https://avatars.githubusercontent.com/u/55075762?v=4"/> <br/> @황승혜](https://github.com/Seunghye-Hwang) |

</div>

<br>

### 황규상

- **UI**
    - 페이지 : 스플래시 뷰, 홈 화면, 장치 연결 탭 화면
- **기능**
    - 일/주/월간 기록, 운동바로가기 버튼, 오늘 날씨 출력, 팔로우 알림 목록, 케이던스 기기 목록 테이블, 케이던스 기기 검색, 장치 상세 화면, 휠 정보 화면, 휠 정보 저장

<br>
    
### 김성국

- **UI**
    - 페이지 : 경쟁 탭 화면
- **기능**
    - 사용자 순위 목록, 거리 선택 드롭다운, 경쟁 거리 선택, 앱과 케이던스 연결, 케이던스 라이딩 데이터 측정, 기록 DB 저장

<br>

### 최광우

- **UI**
    - 페이지 : 마이페이지 탭 화면
- **기능**
    - 로그인 화면, 추가정보 입력 화면, 로그인/회원탈퇴 기능, 회원 정보 수정, 사용자 검색/팔로우, 라이딩 통합 기록 표시 화면, 라이딩 통합 기록 기간별 그래프 표시

<br>

### 황승혜

- **UI**
    - 페이지 : 라이딩 탭 화면
- **기능**
    - 라이딩 기록 화면, 라이딩 시작/Reset/정지/종료 버튼, 종합 라이딩 목록 화면, 라이딩 상세 기록 화면, 라이딩 요약 화면
    
<br>

## 4. 개발 환경

- **개발 환경** 
		- Swift 5.9, Xcode 15.4, IOS 16.6, Node 22.5.1, yarn 1.22.22
- **기술 스택**
		- iOS: UIKit
		- Server: Firebase + Express
		- Database: Firebase Database
		- Software Architecture: MVVM-C
		- Combine + Swift Concurrency
- **Dependencies**
		- Kingfisher 7.12.0 
		- SnapKit 5.7.1 
		- DGChart 5.1.0 
		- Alamofire 5.9.1 
		- TypeScirpt 5.5.4 
		- Express 4.19.2 
		- firebase-admin 12.4.0 -
		- google-auth-libary 9.14.0 
- **서버 Installing**
		- yarn install
- **서버 배포 환경**
		- Vercel
- **협업 도구**
		- Notion, Figma, Github, Discord
