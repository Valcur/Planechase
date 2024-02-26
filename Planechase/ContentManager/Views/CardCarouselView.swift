//
//  CardCarouselView.swift
//  Planechase
//
//  Created by Loic D on 20/02/2024.
//

import SwiftUI


struct CardCarouselView<Content: View, Item, ID>: View where Item: RandomAccessCollection, ID: Hashable, Item.Element: Equatable {
    var content: (Item.Element, CGSize)->Content
    var id: KeyPath<Item.Element, ID>
    
    var spacing: CGFloat
    var cardPadding: CGFloat
    var items: Item
    @Binding var index: Int
    
    // MARK: Gesture properties
    @GestureState var translation: CGFloat = 0
    @State var offset: CGFloat = 0
    @State var lastStoredOffset: CGFloat = 0
    
    @State var currentIndex: Int = 0
    
    // MARK: Extra space calculation
    @State var width: CGFloat = 0
    var cWidth: CGFloat
    
    // MARK: Swipe transition
    @State var rotation: Double = 0
    
    init(index: Binding<Int>, items: Item, cardWidth: CGFloat, spacing: CGFloat = 60, cardPadding: CGFloat = 0, id: KeyPath<Item.Element, ID>, @ViewBuilder content: @escaping (Item.Element, CGSize) -> Content) {
        self.content = content
        self.id = id
        self._index = index
        self.spacing = spacing
        self.cardPadding = cardPadding
        self.items = items
        self.cWidth = cardWidth - (cardPadding - spacing)
    }
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            //let cardWidth = size.width - (cardPadding - spacing)
            //let cardWidth = CardSizes.widthtForHeight(size.height) - (cardPadding - spacing)
            let cardWidth = cWidth
            LazyHStack(spacing: spacing) {
                ForEach(items, id: id) { card in
                    let index = indexOf(item: card)
                    ZStack {
                        content(card, CGSize(width: cardWidth - cardPadding, height: size.height))
                            //.rotationEffect(.init(degrees: Double(index) * 5), anchor: .bottom)
                            //.rotationEffect(.init(degrees: rotation), anchor: .bottom)
                            //.offset(y: offsetY(index: index, cardWidth: cardWidth))

                        // Marche pas si clique vite
                        if index != self.index {
                            Color.black.opacity(0.00001)
                                .onTapGesture {
                                    updateIndex(index * -1, cardWidth: cardWidth)
                                }
                        }
                    }
                    .frame(width: cardWidth - cardPadding, height: size.height)
                   // .opacity(progressionToValue(index: index, cardWidth: cardWidth, maxValue: 0.5) + 0.5)
                    .scaleEffect(progressionToValue(index: index, cardWidth: cardWidth, maxValue: 0.2) + 0.8)
                    .rotation3DEffect(.degrees(progressionSide(index: index, cardWidth: cardWidth) * (20 - progressionToValue(index: index, cardWidth: cardWidth, maxValue: 20))), axis: (x: 0, y: 1, z: 0))
                }
            }.padding(.horizontal, spacing)
            .offset(x: limitScroll())
            .background(Color.black.opacity(0.00001))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($translation, body: { value, out, _ in
                        out = value.translation.width
                    })
                    .onChanged{onChanged(value: $0, cardWidth: cardWidth)}
                    .onEnded{onEnd(value: $0, cardWidth: cardWidth)}
            )
            .onAppear {
                self.width = size.width
                //self.cWidth = cardWidth

                updateIndex(index * -1, cardWidth: cardWidth, useAnimation: false)
            }
        }
        .animation(.easeInOut, value: translation == 0)
    }
    
    // -1 or 1
    func progressionSide(index: Int, cardWidth: CGFloat) -> CGFloat {
        let currentIndex = (offset - extraSpace()) / (cardWidth + spacing) * -1
        let v = currentIndex - CGFloat(index)
        return v < 0 ? -1 : 1
    }
    
    // from 1 if middle to 0 on side
    func progressionToValue(index: Int, cardWidth: CGFloat, maxValue: CGFloat) -> CGFloat {
        let currentIndex = (offset - extraSpace()) / (cardWidth + spacing) * -1
        var v = abs(currentIndex - CGFloat(index))
        v = max(0, (1 - v) * maxValue)
        return v
    }
    
    func indexOf(item: Item.Element) -> Int {
        let array = Array(items)
        if let index = array.firstIndex(of: item) {
            return index
        }
        return 0
    }
    
    func extraSpace() -> CGFloat {
        return (cardPadding / 2) - spacing + (width - cWidth) / 2
    }
    
    func limitScroll() -> CGFloat {
        let extraSpace = extraSpace()
        if index == 0 && offset > extraSpace {
            return extraSpace + (offset / 4)
        } else if index == items.count - 1 && translation < 0 {
            return offset - (translation / 2)
        } else {
            return offset
        }
    }
    
    func onChanged(value: DragGesture.Value, cardWidth: CGFloat) {
        let translationX = value.translation.width
        offset = translationX + lastStoredOffset
    }
    
    func onEnd(value: DragGesture.Value, cardWidth: CGFloat) {
        var newIndex = currentIndex
        let absValue = abs(value.translation.width)
        print(absValue)
        if absValue < 500 && absValue > 80 {
            if value.translation.width > 0 {
                newIndex = currentIndex + 1
            } else {
                newIndex = currentIndex - 1
            }
            if newIndex > 0 {
                newIndex = 0
            } else if newIndex < -items.count + 1 {
                newIndex = -items.count + 1
            }
        } else {
            var _index = ((offset - extraSpace()) / (cardWidth + spacing)).rounded(.toNearestOrAwayFromZero)
            _index = max(-CGFloat(items.count - 1), _index)
            _index = min(_index, 0)
            
            newIndex = Int(_index)
        }
        updateIndex(newIndex, cardWidth: cardWidth)
    }
    
    func updateIndex(_ newIndex: Int, cardWidth: CGFloat, useAnimation: Bool = true) {
        currentIndex = newIndex
        
        let extraSpace = extraSpace()
        
        if useAnimation {
            withAnimation(.easeInOut(duration: 0.25)) {
                offset = (cardWidth + spacing) * CGFloat(newIndex) + extraSpace
                index = -currentIndex
            }
        } else {
            offset = (cardWidth + spacing) * CGFloat(newIndex) + extraSpace
            index = -currentIndex
        }
        lastStoredOffset = offset
    }
}
