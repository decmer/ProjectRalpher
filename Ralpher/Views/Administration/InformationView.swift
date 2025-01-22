//
//  InformationView.swift
//  Ralpher
//
//  Created by Jose Decena on 20/1/25.
//

import SwiftUI

struct InformationView: View {
    @Environment(ViewModel.self) private var vm

    @State var code: String?
    @State var codeVisibility: Bool = false
    @State var newNameSchool: String = ""
    @State var newColorSchool: Color = .black
    
    var body: some View {
        if vm.schoolSelected != nil {
            NavigationStack {
                VStack {
                    Spacer()
                    HStack {
                        Text("Code")
                        Spacer()
                        if code != nil, codeVisibility {
                            CopyableTextView(code!)
                                .frame(width: 150)
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(width: 150, height: 20)
                        }
                        Button {
                            if codeVisibility {
                                withAnimation {
                                    code = nil
                                    codeVisibility = false
                                }
                            } else {
                                Task {
                                    withAnimation {
                                        codeVisibility = false
                                    }
                                    do {
                                        code = try await vm.fetchSchoolsKey()
                                    } catch {
                                        print(error)
                                    }
                                    withAnimation {
                                        codeVisibility = true
                                    }
                                }
                            }
                        } label: {
                            if codeVisibility {
                                Image(systemName: "eye.circle.fill")
                                    .foregroundStyle(.blue)
                                    .frame(width: 20, height: 20)
                            } else {
                                Image(systemName: "eye.slash.circle.fill")
                                    .foregroundStyle(.blue)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        
                    }
                    .padding(.horizontal, 30)
                    
                    HStack {
                        Text("Name School")
                        TextField(vm.schoolSelected?.name ?? "None", text: $newNameSchool)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding([.horizontal, .top], 30)
                    
                    ColorPicker("Pick a color", selection: $newColorSchool)
                    .onAppear {
                        newColorSchool = Color(hex: (vm.schoolSelected?.color)!)
                    }
                    .padding([.horizontal, .top], 30)
                    
                    Spacer()
                    
                    Button {
                        if !newNameSchool.isEmpty {
                            vm.schoolSelected?.name = newNameSchool
                        }
                        vm.schoolSelected?.color = newColorSchool.toHex()
                        Task {
                            do {
                                try await vm.updateSchool()
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .frame(width: 120, height: 40)
                                .foregroundStyle(.blue)
                            Text("Save")
                                .foregroundStyle(.white)
                        }
                    }
                    .padding()
                }
            }
        } else {
            Text("Error")
        }
    }
}

#Preview {
    InformationView()
        .environment(Preview.vm())
}
