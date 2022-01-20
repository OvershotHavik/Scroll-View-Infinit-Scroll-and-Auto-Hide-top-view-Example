//
//  ContentView.swift
//  ScrollViewBottomExample
//
//  Created by Steve Plavetzky on 1/14/22.
//

import SwiftUI



struct AutoHideTopViewScroll: View {
    //Auto hide/show the top view when user scrolls
    @StateObject var vm = InfiniteScrollVM()

    var body: some View {
        NavigationView{
            ZStack(alignment: .top){

                TrackableScrollView(.vertical, contentOffset: $vm.scrollViewContentOffset){

                    LazyVStack{
                        ForEach(vm.data.indices, id: \.self){ cellIndex in
                            let cell = vm.data[cellIndex]
                            Text(cell)
                                .padding(.vertical, 30)
                                .onAppear {
                                    //Once the index hits count -2  then it calls the function to add more to the array
                                    if cellIndex == vm.data.count - 2 {
                                        vm.addData()
                                    }
                                }
                        }
                    }
                }
                if vm.showTopView{
                    Text("Top View")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                }
            }


            .onChange(of: vm.scrollViewContentOffset, perform: { newValue in

                withAnimation(.easeOut){
                    if vm.scrollViewContentOffset < 40{
                        vm.showTopView = true
                    } else {
                        vm.showTopView = false
                    }
                    if vm.scrollViewContentOffset > vm.largestY{
                        //user is scrolling down
                        vm.largestY = vm.scrollViewContentOffset
                        
                    } else {
                        //user started scrolling up again, show the view and set largest Y to current value
                        vm.showTopView = true
                        vm.largestY = vm.scrollViewContentOffset
                    }
                }

                
                
                print("offset value: \(vm.scrollViewContentOffset)")
            })
            .navigationTitle(("Infinit Scroll"))
        }
    }
}


struct ScrollOffsetPreferenceKey: PreferenceKey {
    typealias Value = [CGFloat]
    
    static var defaultValue: [CGFloat] = [0]
    
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}


@available(iOS 13.0, *)
public struct TrackableScrollView<Content>: View where Content: View {
    let axes: Axis.Set
    let showIndicators: Bool
    @Binding var contentOffset: CGFloat
    let content: Content
    
    public init(_ axes: Axis.Set = .vertical, showIndicators: Bool = true, contentOffset: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showIndicators = showIndicators
        self._contentOffset = contentOffset
        self.content = content()
    }
    
    public var body: some View {
        GeometryReader { outsideProxy in
            ScrollView(self.axes, showsIndicators: self.showIndicators) {
                ZStack(alignment: self.axes == .vertical ? .top : .leading) {
                    GeometryReader { insideProxy in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: [self.calculateContentOffset(fromOutsideProxy: outsideProxy, insideProxy: insideProxy)])
                    }
                    VStack {
                        self.content
                    }
                }
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                self.contentOffset = value[0]
            }
        }
    }
    
    private func calculateContentOffset(fromOutsideProxy outsideProxy: GeometryProxy, insideProxy: GeometryProxy) -> CGFloat {
        if axes == .vertical {
            return outsideProxy.frame(in: .global).minY - insideProxy.frame(in: .global).minY
        } else {
            return outsideProxy.frame(in: .global).minX - insideProxy.frame(in: .global).minX
        }
    }
}

