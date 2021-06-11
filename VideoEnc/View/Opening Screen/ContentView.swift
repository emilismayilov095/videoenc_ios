//
//  ContentView.swift
//  VideoEnc
//
//  Created by Muslim on 11.06.2021.
//

import SwiftUI
import TTProgressHUD

struct ContentView: View {
    
    @ObservedObject var model = ViewModel()
    
    
    var body: some View {
        ZStack {
            PlayerView()
                .overlay(Color.black.opacity(0.8))
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Image(systemName: "play.fill")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .padding(.bottom, 30)
                Text("Welcome to")
                    .foregroundColor(.white)
                    .frame(maxWidth: UIScreen.main.bounds.width - 30)
                    .padding(.top, 20)
                Text("VideoEnc")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Spacer()
                Button(action: {
                    self.model.showingPicker.toggle()
                }, label: {
                    Text("Select Video")
                        .foregroundColor(.white)
                })
                .padding()
                .frame(width: UIScreen.main.bounds.width - 100, height: 50, alignment: .center)
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            
            TTProgressHUD($model.loading, config: model.hudConfig)
        }
        .sheet(isPresented: $model.showingPicker,
                onDismiss: {
                }, content: {
                    ImagePicker.shared.view
                })
        .onReceive(ImagePicker.shared.$url) { url in
            self.model.url = url
        }
        .alert(isPresented: $model.showingAlert) {
            Alert(title: Text("Success"), message: Text("Encoded video saved in your library"), dismissButton: .default(Text("OK")))
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
