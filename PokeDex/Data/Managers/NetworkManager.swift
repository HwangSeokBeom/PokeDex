//
//  NetworkManager.swift
//  PokeDex
//
//  Created by Hwangseokbeom on 1/31/26.
//

/*
1) DIP 위반 가능성이 커짐
    •    상위 계층(Repository/UseCase)이 구현체(shared) 에 직접 의존하기 쉬움
→ 테스트/교체가 어려워짐

2) 테스트가 어려워짐
    •    네트워크 호출을 막고 싶어도 shared가 고정이라 Mock 주입이 힘듦
    •    결국 “전역 상태”가 되어 테스트가 흔들림

3) 전역 상태로 결합도가 올라감
    •    여러 테스트/기능에서 공유되면 상태가 섞이기 쉬움 (세션 설정, 캐시 등)
*/
