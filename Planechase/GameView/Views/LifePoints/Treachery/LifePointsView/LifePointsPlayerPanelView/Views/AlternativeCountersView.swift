//
//  AlternativeCountersView.swift
//  LifeCounter
//
//  Created by Loic D on 30/10/2023.
//

import SwiftUI

struct AlternativeCountersView: View {
    @EnvironmentObject var lifePointsViewModel: LifePointsViewModel
    @Binding var counters: [AlternativeCounter]
    let playerId: Int
    @Binding var showAlternativeCounters: Bool
    @State var showCountersList: Bool = false
    let existingCounters = AlternativeCounter.existingCounters
    @State var exitTimer: Timer?
    @State var hasOneOfTheValuesChanged = false
    let maxNumberOfCounters = 4
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
            HStack {
                ForEach(0..<counters.count, id: \.self) { i in
                    if i != 0 {
                        Rectangle()
                            .foregroundColor(.black)
                            .frame(width: 2)
                    } else {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 2)
                    }
                    CounterView(counter: $counters[i], counters: $counters, hasOneOfTheValuesChanged: $hasOneOfTheValuesChanged)
                        .allowsHitTesting(counters[i].enabled)
                    if i == maxNumberOfCounters - 1 {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 2)
                    }
                }
                if counters.count < maxNumberOfCounters {
                    ZStack {
                        Color.black
                        if showCountersList {
                            ScrollView(.vertical) {
                                VStack(spacing: 0) {
                                    ForEach(0..<existingCounters.count, id: \.self) { i in
                                        NewCounterButton(counterName: existingCounters[i], counters: $counters, showCountersList: $showCountersList)
                                    }
                                }.padding(5)
                            }
                        } else {
                            Button(action: {
                                showCountersList = true
                                startExitTimer()
                            }, label: {
                                Image(systemName: "plus")
                                    .font(.title)
                                    .foregroundColor(.white)
                            })
                        }
                    }.frame(maxWidth: counters.count == 0 ? .infinity : 90)
                }
            }
            .onChange(of: counters.count) { _ in
                lifePointsViewModel.saveAlternativeCounters(playerId)
                
                startExitTimer()
            }
            .onChange(of: hasOneOfTheValuesChanged) { _ in
                startExitTimer()
            }
            .onAppear() {
                startExitTimer()
            }
        }
    }

    private func startExitTimer() {
        exitTimer?.invalidate()
        exitTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
            withAnimation(.easeInOut(duration: 0.3)) {
                showAlternativeCounters = false
            }
        }
    }
    
    struct NewCounterButton: View {
        var counterName: String
        @Binding var counters: [AlternativeCounter]
        @Binding var showCountersList: Bool
        @State var isAvailable: Bool = false
        
        var body: some View {
            ZStack {
                if isAvailable {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            counters.append(AlternativeCounter(imageName: counterName, value: 0))
                            showCountersList = false
                        }
                    }, label: {
                        VStack {
                            Image(counterName)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                            Text(counterName)
                                .headline()
                        }
                    }).frame(width: 80, height: 80).background(VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))).cornerRadius(5).padding(.vertical, 3)
                }
            }
            .onAppear() {
                isAvailable = isCounterAvailable(counterName)
            }
        }
        
        func isCounterAvailable(_ counterName: String) -> Bool {
            for counter in counters {
                if counter.imageName == counterName {
                    return false
                }
            }
            return true
        }
    }
    
    struct CounterView: View {
        @Binding var counter: AlternativeCounter
        @Binding var counters: [AlternativeCounter]
        @Binding var hasOneOfTheValuesChanged: Bool
        @State var prevValue: CGFloat = 0
        
        var body: some View {
            ZStack(alignment: .bottom) {
                VStack(alignment: .center) {
                    Spacer()
                    Text("\(counter.value)")
                        .title()
                    Image(counter.imageName)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                    Spacer()
                }.frame(maxWidth: .infinity)
                VStack(spacing: 0) {
                    Rectangle()
                        .opacity(0.0001)
                        .onTapGesture {
                            counter.value += 1
                            hasOneOfTheValuesChanged.toggle()
                        }
                    Rectangle()
                        .foregroundColor(.white).frame(height: 1).opacity(0.7)
                    Rectangle()
                        .opacity(0.0001)
                        .onTapGesture {
                            if counter.value > 0 {
                                counter.value -= 1
                                hasOneOfTheValuesChanged.toggle()
                            }
                        }
                }
                .gesture(DragGesture()
                    .onChanged { value in
                        let newValue = value.translation.height
                        if newValue > prevValue + 12 {
                            prevValue = newValue
                            if counter.value > 0 {
                                counter.value -= 1
                                hasOneOfTheValuesChanged.toggle()
                            }
                        }
                        else if newValue < prevValue - 12 {
                            prevValue = newValue
                            counter.value += 1
                            hasOneOfTheValuesChanged.toggle()
                        }
                    }
                    .onEnded({ _ in
                        hasOneOfTheValuesChanged.toggle()
                    })
                )
                Button(action: {
                    counter.enabled = false
                    withAnimation(.easeInOut(duration: 0.3)) {
                        counters.removeAll(where: { $0.imageName == counter.imageName })
                    }
                }, label: {
                    ZStack {
                        Color.black.opacity(0.00002)
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }).frame(height: 40)
            }
        }
    }
}

struct AlternativeCounter {
    static let existingCounters = ["Poison", "XP", "Treasure", "Tax", "Energy"]
    var imageName: String
    var value: Int
    var enabled: Bool = true
}
