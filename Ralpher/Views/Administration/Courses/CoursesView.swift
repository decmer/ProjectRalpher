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
    @State var featchCourseRetry = false
    
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
            if let coursesFilter = coursesFilter, let courses = vm.course {
                if !courses.isEmpty {
                    ScrollView {
                        LazyVStack {
                            ForEach(searchableSTR.isEmpty ? courses : coursesFilter) { course in
                                NavigationLink {
                                    previewCourse(course)
                                    //                                    .onDisappear() {
                                    //                                        vm.courseSelected = nil
                                    //                                    }
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
                            //                        vm.courseSelected = nil
                        }
                    }
                } else {
                    Text("There is no course created")
                }
            } else {
                
                LoadScreenView()
                    .onAppear {
                        Task {
                            while true {
                                do {
                                    vm.course = try await vm.fetchCourse()
                                    break
                                } catch {
                                    vm.messageError = error.localizedDescription
                                    sleep(5)
                                }
                            }
                        }
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) {
                            DispatchQueue.main.sync {
                                withAnimation {
                                    featchCourseRetry = true
                                }
                            }
                        }
                    }
                if featchCourseRetry {
                    Button("Retry", action: {
                        Task {
                            do {
                                vm.course = try await vm.fetchCourse()
                            } catch {
                                vm.messageError = error.localizedDescription
                            }
                        }
                    })
                }
            }
        }
        .sheet(isPresented: $isPresented) {
            CourseAddView(isPresented: $isPresented)
                .presentationDetents([.fraction(0.25)])
        }
    }
    
    private func previewCourse(_ course: CourseModel) -> some View {
        CourseSelected(name: course.name)
            .onAppear {
                if let index = vm.cacheCourse.firstIndex(where: { $0.0.id == course.id! }) {
                    vm.courseSelected = vm.cacheCourse[index]
                    vm.userToCourse = vm.cacheCourse[index].1
                    vm.classToCourse = vm.cacheCourse[index].2
                } else {
                    Task {
                        do {
                            let caheAux: ([UserModel], [ClassModel])? = try await vm.prepareCacheCourseUsersSchool(course.id!)
                            vm.courseSelected = (course, caheAux!.0, caheAux!.1)
                            vm.userToCourse = caheAux?.0
                            vm.classToCourse = caheAux?.1
                        } catch {
                            vm.messageError = error.localizedDescription
                        }
                    }
                }
            }
    }
}

#Preview {
    CoursesView()
        .environment(Preview.vm())
}
