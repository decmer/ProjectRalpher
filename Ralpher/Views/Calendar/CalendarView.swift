//
//  CalendarView.swift
//  Ralpher
//
//  Created by Jose Decena on 22/1/25.
//

import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showMonthPicker = false
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var isYearPickerVisible = false
    @State private var tempSelectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var dragOffset: CGFloat = 0

    private var calendar: Calendar {
        Calendar.current
    }

    private var months: [String] {
        calendar.monthSymbols
    }

    // Genera un rango de años de 50 años antes hasta 50 años después del año seleccionado
    private var years: [Int] {
        let lowerBound = selectedYear - 50
        let upperBound = selectedYear + 50
        return Array(lowerBound...upperBound)
    }

    private var daysInMonth: [Date] {
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        var days: [Date] = []

        // Calcular el día de la semana del primer día del mes.
        let weekdayOfFirstDay = (calendar.component(.weekday, from: firstDayOfMonth) - calendar.firstWeekday + 7) % 7
        
        // Agregar días vacíos antes del primer día del mes.
        for _ in 0..<weekdayOfFirstDay {
            days.append(Date.distantPast) // Días vacíos
        }

        // Agregar los días reales del mes.
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }

        // Completar la última fila con días vacíos si es necesario.
        let totalDaysInGrid = days.count
        let remainingDays = totalDaysInGrid % 7
        if remainingDays > 0 {
            let daysToAdd = 7 - remainingDays
            for _ in 0..<daysToAdd {
                days.append(Date.distantPast) // Agregar días vacíos
            }
        }

        return days
    }

    private var startOfMonth: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
    }

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {
                        showMonthPicker = true
                    }) {
                        Text(months[selectedMonth - 1])
                            .font(.title)
                            .padding()
                    }
                    .actionSheet(isPresented: $showMonthPicker) {
                        ActionSheet(
                            title: Text("Seleccionar mes"),
                            buttons: months.enumerated().map { index, month in
                                .default(Text(month)) {
                                    selectedMonth = index + 1
                                    updateCurrentMonth()
                                }
                            } + [.cancel()]
                        )
                    }

                    Button(action: {
                        withAnimation {
                            isYearPickerVisible = true
                        }
                    }) {
                        Text("\(String(selectedYear))")
                            .font(.title)
                            .padding()
                    }
                }

                // Mostrar días de la semana
                let weekdaySymbols = calendar.shortWeekdaySymbols
                HStack {
                    ForEach(weekdaySymbols, id: \.self) { weekday in
                        Text(weekday)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 10)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                // Mostrar los días del mes
                let rows = daysInMonth.chunked(into: 7) // Agrupar los días en semanas
                ForEach(rows, id: \.self) { row in
                    HStack {
                        ForEach(row, id: \.self) { day in
                            if day != Date.distantPast { // No mostrar los días vacíos
                                Button(action: {
                                    selectedDate = day
                                }) {
                                    VStack {
                                        Text("\(calendar.component(.day, from: day))")
                                            .padding()
                                            
                                        Spacer()
                                    
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(8)
                                    .background(selectedDate == day ? Color.blue : Color.clear)
                                    .foregroundColor(selectedDate == day ? .white : .primary)
                                    .cornerRadius(8)
                                    
                                }
                            } else {
                                Text("")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                }
            }

            // Si el Picker de año es visible, superponerlo en la parte superior
            
                
        }
        .ignoresSafeArea()
        .padding()
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    // Solo cambia de mes si el desplazamiento es suficiente
                    if abs(dragOffset) > 100 {
                        if dragOffset < 0 {
                            // Si el desplazamiento es hacia la izquierda, avanzar al siguiente mes
                            goToNextMonth()
                        } else {
                            // Si el desplazamiento es hacia la derecha, retroceder al mes anterior
                            goToPreviousMonth()
                        }
                    }
                    // Restablecer el offset del gesto
                    dragOffset = 0
                }
        )
        .overlay {
            if isYearPickerVisible {
                Color.black.opacity(0.3) // Fondo semi-transparente
                                    .edgesIgnoringSafeArea(.all)
                                    .onTapGesture {
                                        withAnimation {
                                            isYearPickerVisible = false
                                        }
                                    }
                
                
                ZStack {
                    VStack {
                        Spacer()
                        Picker("Año", selection: $tempSelectedYear) {
                            ForEach(years, id: \.self) { year in
                                Text("\(String(year))")
                                    .foregroundStyle(.black)
                                    .tag(year)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 150)
                        .clipped()
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding()
                        
                        Button(action: {
                            // Actualizar el año seleccionado cuando se presiona "Aceptar"
                            selectedYear = tempSelectedYear
                            updateCurrentMonth()
                            isYearPickerVisible = false
                        }) {
                            Text("Aceptar")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Capsule().fill(Color.white).shadow(radius: 5))
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }

    // Función para actualizar el mes y el año
    private func updateCurrentMonth() {
        let components = DateComponents(year: selectedYear, month: selectedMonth)
        if let newMonth = calendar.date(from: components) {
            currentMonth = newMonth
        }
    }

    // Función para ir al siguiente mes
    private func goToNextMonth() {
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = nextMonth
            selectedMonth = calendar.component(.month, from: nextMonth)
            selectedYear = calendar.component(.year, from: nextMonth)
            tempSelectedYear = selectedYear
        }
    }

    // Función para ir al mes anterior
    private func goToPreviousMonth() {
        if let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = previousMonth
            selectedMonth = calendar.component(.month, from: previousMonth)
            selectedYear = calendar.component(.year, from: previousMonth)
            tempSelectedYear = selectedYear
        }
    }
}

extension Array {
    // Método para dividir un array en subarrays de tamaño determinado
    func chunked(into size: Int) -> [[Element]] {
        var chunks: [[Element]] = []
        var currentChunk: [Element] = []
        
        for item in self {
            currentChunk.append(item)
            if currentChunk.count == size {
                chunks.append(currentChunk)
                currentChunk = []
            }
        }
        
        if !currentChunk.isEmpty {
            chunks.append(currentChunk)
        }
        
        return chunks
    }
}

#Preview {
    CalendarView()
}
