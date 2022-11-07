한양대학교 ERICA 소프트웨어학부 2022년 2학기

![COMPUTSERICA](https://i.imgur.com/3A8uLLH.png)

소리 합성과 음악 연주에 특화된 프로그래밍 언어인 ChucK을 사용하여, 음악을 연주하는 소프트웨어를 창작하는데 필요한 프로그램 논리와 기술을 배우고, 다양한 음악 창작 프로그래밍 실습과 작품발표 콘서트를 통하여 컴퓨터음악을 창작할 수 있는 기본기를 닦는다.

### 수업목표

-	ChucK 프로그래밍 언어 프로그램 구조의 구문과 실행 의미 습득
-	ChucK 프로그래밍 환경에서 코딩 작성 능력 배양
-	다양한 실물 악기 라이브러리 및 합주 창작 능력 함양
-	MIDI, OSC를 활용하여 연주 소프트웨어 창작을 위한 능력 습득

### 교재

- 도경구, 강의 노트

### 참고 문헌
-	Ajay Kapur, Perry Cook, Spencer Salazar, and Ge Wang, [Programming for Musicians and Digital Artists - Creating Music with ChucK](https://www.manning.com/books/programming-for-musicians-and-digital-artists), Manning Publications Co., 2015. [저자 강의 비디오](https://www.kadenze.com/courses/introduction-to-programming-for-musicians-and-digital-artists/info)
-	Michael Hewitt, Music Theory for Computer Musicians, Course Technology, 2008.

### 소프트웨어

- [ChucK : Strongly-timed, Concurrent, and On-the-fly Music Programming Language](https://chuck.cs.princeton.edu/)
- [VIRTUAL MIDI PIANO KEYBOARD](http://vmpk.sourceforge.net/) : VMPK is a MIDI-event generator and receiver
- [가상 포트 설치하기](https://hushed-slouch-a9e.notion.site/CSE2020-bfe154f28ebf484b85b728881645e98e)

### 참고

- [COMPUTSERICA Recital 2020 Video](https://youtu.be/Z_QCXaJ7Z0E)

### 수업 시간 및 장소

-	강의 : 수 15:00-17:00, 학연산클러스터지원센터 203호, 개인 노트북 지참 필수
-	실습 : 목 09:00-11:00, 제4공학관 106호 IC-PBL강의실, 개인 노트북 지참 필수


### 수업 일정

| 주 | 강의 | 실습 | 내용 | 숙제 |
|:--:|:--:|:--:|:--:|:--:|
| 1  | 9/1 | - | 1. [음악 프로그래밍 소개](notes/notes01.md), [2021.09.02](https://youtu.be/N5kVgNkZjoU) | [샘플 프로그램](code/sample.zip) |
| 2  | 9/7 | 9/8 | 2. [소리내기 프로그래밍 기본](notes/notes02.md), [2021.09.09](https://youtu.be/yqndPm9CIg4) | #1 마감 9/19(월) 자정 |
| 3  | 9/14 | 9/15 | 3. [함수 요약](notes/notes03.md) | #2 마감 9/21(수) 오후3시 |
| 4  | [9/21](https://youtu.be/o330sPWhLOA) | [9/22](https://youtu.be/HPKKIAmTlCs) | 4. [배열](notes/notes04.md) | #3 마감 9/28(수) 오후3시 |
| 5  | [9/28](https://youtu.be/VcJLnrlCzg4) | [9/29](https://youtu.be/thtWJbKJblg) | 5. [소리 파일 다루기](notes/notes05.md), [audio.zip](code/audio.zip) | #4 마감 10/5(수) 오후3시 |
| 6  | [10/5](https://youtu.be/5yFuBfmh-_E) | [10/6](https://youtu.be/4P4AvuCmldA) | 6. [소리 합성 및 다듬기 - `UGen`의 활용](notes/notes06.md) | #5 마감 10/12(수) 오후3시 |
| 7  | [10/12](https://youtu.be/3OW8s-AFYnQ) | - | 리뷰 | [기출문제 및  모범답안](notes/CSE2020-2021exam1sol.pdf) |
| 7  | - | 10/13 | 시험#1 | [문제 및 답안](notes/CSE2020-2022exam1sol.pdf) |
| 8  | [10/19](https://youtu.be/wpN016mUNHo) | [10/20](https://youtu.be/IjtnlVbTdkA) | 7. [멀티스레드와 동시 계산](notes/notes07.md), [완성 코드](notes/notes07sol.md) | #6 마감 10/26(수) 오후3시 |
| 9  | [10/26](https://youtu.be/7PvV8F7fd6w) | [10/27](https://youtu.be/0JBxkdCd7UE) | 8. [객체와 클래스](notes/notes08.md) | #7 마감 11/2(수) 오후3시 |
| 10 | 11/2 | [11/3](https://youtu.be/Oj434EyrpGw) | 9. [이벤트 구동 프로그래밍](notes/notes09.md) | #8 마감 11/9(수) 오후 3시 |
| 11 | 11/9 | - | 10. [MIDI, OSC](notes/notes10.md) | - |
| 11 | - | 11/10 | 리뷰 | [기출문제](notes/CSE2020-2021exam2.pdf) 및  모범답안 |
| 12 | 11/16 | - | 시험#2 | - |
| 13 | 11/23 | 11/24 | 프로젝트 기획 | - |
| 14 | 11/30 | 12/1 | 프로젝트 리허설 | - |
| 15 | 12/7 | 12/8 | 프로젝트 발표 | - |

### 평가

| 항목 | 비율 | 세부 내용 |
|:---:|:---:|:---:|
| 강의 | 10% | 무단 결석 -1%, 지각 -0.5% |
| 실습 | 10% | 미제출 또는 무단 결석 -1%, 지각 -0.5% |
| 숙제 | 20% | 2.5% x 8 |
| 팀프로젝트 | 10% | 기획 3% + 리허설 2% + 발표 5% |
| 시험 1 & 2 | 50% | 25% x 2 |
| 합계 | 100% |  |

### 수업 윤리

- 다른 학생의 코드를 그대로 베껴서 제출하면 부정행위로 간주되어 해당 학생 모두 0점 처리됩니다. 모여서 토론하며 공부하는 건 장려하지만 코드는 본인 스스로 작성해야 합니다.
- 시험에서 부정행위가 발견되면 즉시 F학점 처리됩니다.

### 교수진

- 교수: [도경구](http://doggzone.github.io/home)(doh@hanyang.ac.kr), 제4공학관 3층 320호
- 조교: 모지환(gugusny5758@gmail.com), 제4공학관 3층 319호 프로그래밍언어연구실
