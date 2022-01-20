//
//  InfinitScroll.swift
//  ScrollViewBottomExample
//
//  Created by Steve Plavetzky on 1/20/22.
//

import SwiftUI

class InfiniteScrollVM: ObservableObject{
    @Published var data : [String] = ["initial data"]
    @Published var scrollViewContentOffset = CGFloat(0)
    @Published var largestY = CGFloat(0)
    @Published var showTopView = true
    init(){
        addData()
    }
    func addData(){
        print("Add data ")
        for index in 0...30{
            data.append("index: \(index)")
        }
    }
}
//Infinit scroll
struct InfiniteScroll: View {
    @StateObject var vm = InfiniteScrollVM()
    
    var body: some View {
        NavigationView{
            ScrollView{
                LazyVStack{
                    ForEach(vm.data.indices, id: \.self){ cellIndex in
                        let cell = vm.data[cellIndex]
                        Text(cell)
                            .padding(.vertical, 30)
                            .onAppear {
                                //Once the index hits -2 count then it calls the function to add more to the array
                                if cellIndex == vm.data.count - 2 {
                                    vm.addData()
                                }
                            }
                    }
                }

            }

            .navigationTitle(("Infinit Scroll"))
        }
    }
}

struct InfiniteScroll_Previews: PreviewProvider {
    static var previews: some View {
        InfiniteScroll()
    }
}
