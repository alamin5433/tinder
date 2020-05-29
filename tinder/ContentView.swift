//
//  ContentView.swift
//  tinder
//
//  Created by Al Amin on 27/5/20.
//  Copyright © 2020 Al Amin. All rights reserved.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct ContentView: View {
    @EnvironmentObject var obs: observer
    var body: some View {
        ZStack {
            Color("LightWhite").edgesIgnoringSafeArea(.all)
            if obs.users.isEmpty {
                Loader()
            }
            
            VStack {
                TopView()
                SwipView()
                BottomView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TopView: View {
    var body: some View {
        HStack{
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                Image("person")
                    .resizable()
                    .frame(width: 35, height: 35)
            }
            .foregroundColor(.gray)
            
            Spacer()
            
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                Image(systemName: "flame.fill")
                    .resizable()
                    .frame(width: 35, height: 30)
            }
            .foregroundColor(.red)
            Spacer()
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                Image("chat")
                    .resizable()
                    .frame(width: 35, height: 35)
            }
            .foregroundColor(.gray)
        }
        .padding()
    }
}

struct BottomView: View {
    var body: some View {
        HStack(spacing: 10){
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                Image("reload")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding()
                
            }
            .foregroundColor(.yellow)
            .background(Color.white)
            .shadow(radius: 25)
            .clipShape(Circle())
            
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                Image("clear")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding()
                
            }
            .foregroundColor(.red)
            .background(Color.white)
            .shadow(radius: 25)
            .clipShape(Circle())
            
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                Image("star")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding()
                
            }
            .foregroundColor(.blue)
            .background(Color.white)
            .shadow(radius: 25)
            .clipShape(Circle())
            
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                Image("heart")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding()
                
            }
            .foregroundColor(.blue)
            .background(Color.white)
            .shadow(radius: 25)
            .clipShape(Circle())
            
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/) {
                Image("current")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding()
                
            }
            .foregroundColor(.purple)
            .background(Color.white)
            .shadow(radius: 25)
            .clipShape(Circle())
        }
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom == 0 ? 15 : 0)
    }
}

struct SwipView : View {
    @EnvironmentObject var obser:observer
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(self.obser.users){ i in
                    
                    SwipeDetailView(name: i.name, age: i.age, image: i.image, height: geo.size.height - 100).gesture(DragGesture()
                        .onChanged({ (value) in
                            if value.translation.width > 0 {
                                self.obser.update(id: i, value: value.translation.width, degree: 8)
                            }else{
                                self.obser.update(id: i, value: value.translation.width, degree: -8)
                            }
                        })
                        .onEnded({ (values) in
                            if i.swipe > 0{
                                if i.swipe > geo.size.width / 2 - 80 {
                                    self.obser.update(id: i, value: 500, degree: 0)
                                }else{
                                     self.obser.update(id: i, value: 0, degree: 0)
                                }
                            }else{
                                if -i.swipe > geo.size.width / 2 - 80 {
                                    self.obser.update(id: i, value: -500, degree: 0)
                                }else{
                                     self.obser.update(id: i, value: 0, degree: 0)
                                }
                            }
                        })
                    )
                        .offset(x: i.swipe)
                        .rotationEffect(.init(degrees: i.degree))
                        .animation(.spring())
                    
                }
            }
            .padding(.horizontal)
        }
    }
}

class observer : ObservableObject {
   @Published var users = [datatype]()
   
    init() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { (snap, err) in
            if err != nil {
                print(err?.localizedDescription ?? "error")
                return
            }
            for i in snap!.documents{
                let name = i.get("name") as! String
                let age = i.get("age") as! String
                let image = i.get("image") as! String
               // self.id += 1
                let id = i.documentID
                self.users.append(datatype(id: id, name: name, image: image, age: age, swipe: 0, degree: 0))
                //self.users.append(datatype(id: self.id, name: name))
            }
        }
    }
    
    func update(id: datatype, value: CGFloat, degree: Double) {
        for i in 0..<self.users.count {
            if self.users[i].id == id.id {
                self.users[i].swipe = value
                self.users[i].degree = degree
            }
        }
    }
}

struct datatype : Identifiable {
    var id: String
    var name : String
    var image : String
    var age : String
    var swipe : CGFloat
    var degree: Double
}


struct Loader : UIViewRepresentable {
   
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        return indicator
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        
    }
}

struct SwipeDetailView : View {
    var name = ""
    var age = ""
    var image = ""
    var height: CGFloat = 0
    var body: some View {
        
        
        ZStack(alignment: .bottomLeading) {
            AnimatedImage(url: URL(string: image)!)
                .resizable()
                .frame(height: height)
                .cornerRadius(20)
            VStack(alignment: .leading, spacing: 10) {
                Text(name)
                    .fontWeight(.heavy)
                    .font(.system(size: 25))
                    .foregroundColor(.white)
                Text(age)
                .foregroundColor(.white)
            }
            .padding([.leading, .bottom],30)
        }
    }
}
