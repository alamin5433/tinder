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
   
    var body: some View {
        ZStack {
            Loader()
            VStack {
                    TopView()
                    SwipeView()
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
            Button(action: {
                
            }) {
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

struct SwipeView : View {
    @EnvironmentObject var obser : observer
    var body: some View{
        GeometryReader{ geo in
            ZStack{
                ForEach(self.obser.users){ i in
                    //Image(i.image)
//                    AnimatedImage(url: URL(string: i.image))
//                    .resizable()
//                        .frame(height: geo.size.height - 100)
//                    .cornerRadius(20)
                    
                    SwipeDetailView(name: i.name, age: i.age, image: i.image).frame(height: geo.size.height - 100)
                    .gesture(DragGesture()
                        .onChanged({ (Value) in
                            if Value.translation.width > 0{
                                self.obser.update(ob: i, value: Value.translation.width, degree: 8)
                            }else{
                                self.obser.update(ob: i, value: Value.translation.width, degree: -8)
                            }
                            
                        })
                        .onEnded({ (value) in
                            if i.swipe > 0 {
                                if i.swipe > geo.size.width / 2 - 80 {
                                    self.obser.update(ob: i, value: 500, degree: 8)
                                }else{
                                    self.obser.update(ob: i, value: 0, degree: 0)
                                }
                            }else{
                                if -i.swipe > geo.size.width / 2 - 80 {
                                    self.obser.update(ob: i, value: -500, degree: -8)
                                }else{
                                    self.obser.update(ob: i, value: 0, degree: 0)
                                }
                            }
                        })
                    )
                        .offset(x: i.swipe)
                        .rotationEffect(.init(degrees: i.degree))
                        .animation(.spring())
                }
            }
            .padding(.horizontal, 15)
        }
    }
}

struct SwipeDetailView: View {
    var name = ""
    var age = ""
    var image = ""
    //var height:CGFloat = 0
    var body: some View{
        ZStack{
            AnimatedImage(url: URL(string: image))
            .resizable()
               // .frame(height: geo.size.height - 100)
            .cornerRadius(20)
            VStack(alignment:.leading){
                Text(name).fontWeight(.heavy).font(.system(size: 20)).foregroundColor(.white)
                Text(age)
            }
        }
    }
}

class observer: ObservableObject {
    @Published var users = [datatype]()
    init() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { (snap, err) in
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            for i in snap!.documents{
                let name = i.get("name") as! String
                let age = i.get("age") as! String
                let image = i.get("image") as! String
                let id = i.documentID
                self.users.append(datatype(id: id, name: name, image: image, age: age, swipe: 0, degree: 0))
            }
        }
    }
    
    func update(ob: datatype , value: CGFloat, degree: Double) {
        for i in 0..<self.users.count {
            if self.users[i].id == ob.id {
                self.users[i].swipe = value
                self.users[i].degree = degree
            }
        }
    }
}

struct Loader: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView{
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        return indicator
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        
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





