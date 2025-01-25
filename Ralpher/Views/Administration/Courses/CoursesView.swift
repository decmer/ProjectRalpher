//
//  CoursesView.swift
//  Ralpher
//
//  Created by Jose Decena on 25/1/25.
//

import SwiftUI

struct CoursesView: View {
    @Environment(ViewModel.self) private var vm
    
    @State var searchableSTR = ""
    @State var isPresented = false
    
    
    var coursesFilter: [CourseModel]? {
        if vm.course != nil {
            let filteredSchools: [CourseModel] = vm.course!.filter {
                $0.name.lowercased().contains(searchableSTR.lowercased())
            }
            return filteredSchools
        } else {
            return nil
        }
    }
    
    var body: some View {
        NavigationStack {
            if let coursesFilter = coursesFilter, let courses = vm.course, !courses.isEmpty {
                LazyAdapList(preferredWidth: 350) {
                    ForEach(searchableSTR.isEmpty ? courses : coursesFilter) { course in
                        NavigationLink {
                            CourseSelected(name: course.name)
                                .onAppear {
                                    if let index = vm.cacheCourse.firstIndex(where: { $0.0.id == course.id! }) {
                                        vm.courseSelected = vm.cacheCourse[index]
                                        vm.userToCourse = vm.cacheCourse[index].1
                                    }
                                }
                        } label: {
                            CoursePreview(course: course)
                                
                        }
                        .padding(.top)
                        .onDisappear {
                            Task {
                                if let index = vm.cacheCourse.firstIndex(where: { $0.0.id == course.id! }) {
                                    vm.cacheCourse.remove(at: index)
                                }
                            }
                        }
                        .onAppear {
                            Task {
                                do {
                                    let prepareCache = try await vm.prepareCacheCourseUsersSchool(course.id!)
                                    if let prepareCache = prepareCache {
                                        vm.cacheCourse.append((course, prepareCache.0, prepareCache.1))
                                    }
                                } catch {
                                    vm.messageError = error.localizedDescription
                                }
                            }
                        }
                    }
                }
                .toolbar {
                    Button {
                        isPresented = true
                    } label: {
                        Text("add")
                    }
                }
                .searchable(text: $searchableSTR)
                .navigationTitle("Courses")
                .onAppear {
                    vm.courseSelected = nil
                }
            } else {
                Text("Hello, World!")
                    .navigationTitle("Courses")
                    .toolbar {
                        Button {
                            isPresented = true
                        } label: {
                            Text("add")
                        }
                    }
            }
        }
        .sheet(isPresented: $isPresented) {
            CourseAddView(isPresented: $isPresented)
                .presentationDetents([.fraction(0.25)])
        }
    }
}

#Preview {
    CoursesView()
        .environment(Preview.vm())
}
