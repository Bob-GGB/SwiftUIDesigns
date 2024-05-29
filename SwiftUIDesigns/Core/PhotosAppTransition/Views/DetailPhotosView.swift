//
//  DetailPhotosView.swift
//  SwiftUIDesigns
//
//  Created by xqsadness on 29/05/2024.
//

import SwiftUI

struct DetailPhotosView: View {
    
    @Environment(UICoordinator.self) private var coordinator
    
    var body: some View {
        VStack(spacing: 0){
            NavigationBar()
            
            GeometryReader{
                let size = $0.size
                
                ScrollView(.horizontal){
                    LazyHStack(spacing: 0){
                        ForEach(coordinator.items){ item in
                            //Image view
                            ImageView(item, size: size)
                        }
                    }
                    .scrollTargetLayout()
                }
                //Making it as a paging view
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: .init(get: {
                    return coordinator.detailScrollPosition
                }, set: {
                    coordinator.detailScrollPosition = $0
                }))
                .onChange(of: coordinator.detailScrollPosition, { oldValue, newValue in
                    coordinator.didDetailPageChanged()
                })
                .background{
                    if let selectedItem = coordinator.selectedItem{
                        Rectangle()
                            .fill(.clear)
                            .anchorPreference(key: HeroKey.self,value: .bounds, transform: { anchor in
                                return [selectedItem.id + "DEST": anchor]
                            })
                    }
                }
                .offset(coordinator.offset)
                
                Rectangle()
                    .foregroundStyle(.clear)
                    .frame(width: 10)
                    .contentShape(.rect)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged{ value in
                                let translation = value.translation
                                coordinator.offset = translation
                                //Progress for fading out the detail view
                                let heightProgress = max(min(translation.height / 200, 1), 0)
                                coordinator.dragProgress = heightProgress
                            }
                            .onEnded{ value in
                                let translation = value.translation
                                let velocity = value.velocity
                                let width = translation.width + (velocity.width / 5)
                                let height = translation.height + (velocity.height / 5)
                                
                                if height > (size.height * 0.5){
                                    //Close view
                                    coordinator.tooogleView(show: false)
                                }else{
                                    //Reset to origin
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        coordinator.offset = .zero
                                        coordinator.dragProgress = 0
                                    }
                                }
                            }
                    )
            }
            .opacity(coordinator.showDetailView ? 1 : 0)
            
            BottomIndicatorView()
                .offset(y: coordinator.showDetailView ? (120 * coordinator.dragProgress) : 120)
                .animation(.easeInOut(duration: 0.15), value: coordinator.showDetailView)
        }
        .onAppear{
            coordinator.tooogleView(show: true)
        }
    }
    
    //Custom navigation bar
    @ViewBuilder
    func NavigationBar() -> some View{
        HStack{
            Button{
                coordinator.tooogleView(show: false)
            }label: {
                HStack(spacing: 2){
                    Image(systemName: "chevron.left")
                        .font(.title3)
                    
                    Text("Back")
                }
            }
            
            Spacer(minLength: 0)
            
            Button{
                
            }label: {
                HStack(spacing: 2){
                    Image(systemName: "ellipsis")
                        .padding(13)
                        .background(.bar, in: .circle)
                }
            }
            
        }
        .padding([.top, .horizontal], 15)
        .padding(.bottom, 10)
        .background(.ultraThinMaterial)
        .offset(y: coordinator.showDetailView ? (-120 * coordinator.dragProgress) : -120)
        .animation(.easeInOut(duration: 0.15), value: coordinator.showDetailView)
    }
    
    @ViewBuilder
    func ImageView(_ item: ItemPhotoTransition, size: CGSize) -> some View{
        if let image = item.image{
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size.width, height: size.height)
                .clipped()
                .contentShape(.rect)
        }
    }
    
    // Bottom indicator view
    @ViewBuilder
    func BottomIndicatorView() -> some View{
        GeometryReader{
            let size = $0.size
            
            ScrollView(.horizontal){
                LazyHStack(spacing: 5){
                    ForEach(coordinator.items){ item in
                        //preview image view
                        if let image = item.previewImage{
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(.rect(cornerRadius: 10))
                                .scaleEffect(0.97)
                        }
                    }
                }
                .padding(.vertical, 10)
                .scrollTargetLayout()
            }
            .safeAreaPadding(.horizontal, (size.width - 50) / 2)
            //Active indicator icon
            .overlay{
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.primary, lineWidth: 3)
                    .frame(width: 50, height: 50)
                    .allowsHitTesting(false)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: .init(get: {
                return coordinator.detailIndicatorPosition
            }, set: {
                coordinator.detailIndicatorPosition = $0
            }))
            .scrollIndicators(.hidden)
            .onChange(of: coordinator.detailIndicatorPosition) { oldValue, newValue in
                coordinator.didDetailIndicatorPageChanged()
            }
        }
        .frame(height: 70)
        .background{
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    PhotosAppTransitionView()
}
