//
//  ScheduleLogic.swift
//  Ralpher
//
//  Created by Jose Decena on 23/1/25.
//

import Foundation
struct Clase {
    let id: Int
    let duracion: Int // Duración en minutos (45-90)
    let horasSemanales: Int
    var horario: [(dia: String, horaInicio: String, horaFin: String)] = []
}

struct Profesor {
    let id: UUID
    let limiteHorasSemanales: Int? // nil indica que no tiene límite
    var horasAsignadas: Int = 0
    var clases: [Clase] = []

    mutating func agregarClase(_ clase: Clase, duracionClase: Int, dia: String, horaInicio: String, horaFin: String) {
        if !clases.contains(where: { $0.id == clase.id }) {
            var nuevaClase = clase
            nuevaClase.horario.append((dia: dia, horaInicio: horaInicio, horaFin: horaFin))
            clases.append(nuevaClase)
            horasAsignadas += duracionClase / 60
        }
    }
}

struct Curso {
    let id: Int
    var clases: [Clase]
}

func generarHorario(cursos: [Curso], profesores: [Profesor]) {
    var profesores = profesores
    let diasSemana = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes"]
    let horarioInicio = 8 * 60 + 30 // 8:30 en minutos desde medianoche
    let horarioFin = 15 * 60 // 15:00 en minutos desde medianoche
    let recreoInicio = 12 * 60 + 30 // 12:30 en minutos desde medianoche
    let recreoFin = 13 * 60 // 13:00 en minutos desde medianoche

    for curso in cursos {
        for i in 0..<curso.clases.count {
            let clase = curso.clases[i]
            var horasRestantes = clase.horasSemanales
            var diaIndex = 0
            var horaActual = horarioInicio

            while horasRestantes > 0 && diaIndex < diasSemana.count {
                let dia = diasSemana[diaIndex]

                if horaActual >= recreoInicio && horaActual < recreoFin {
                    horaActual = recreoFin // Saltar el recreo
                }

                let duracionClase = min(clase.duracion, horasRestantes * 60)
                let horaFin = horaActual + duracionClase

                if horaFin <= horarioFin {
                    // Buscar un profesor disponible
                    if let profesorIndex = profesores.firstIndex(where: { profesor in
                        (profesor.limiteHorasSemanales == nil || profesor.horasAsignadas + duracionClase / 60 <= profesor.limiteHorasSemanales!) &&
                        !profesor.clases.contains(where: { $0.horario.contains(where: { $0.dia == dia && horasSeSolapan(horaActual, $0.horaInicio, horaFin, $0.horaFin) }) })
                    }) {
                        // Asignar horario
                        profesores[profesorIndex].agregarClase(
                            clase,
                            duracionClase: duracionClase,
                            dia: dia,
                            horaInicio: minutosAHora(horaActual),
                            horaFin: minutosAHora(horaFin)
                        )

                        horaActual = horaFin // Avanzar al siguiente intervalo
                        horasRestantes -= duracionClase / 60
                    } else {
                        // Si no hay profesores disponibles, saltar a la próxima franja horaria
                        horaActual += duracionClase
                    }
                } else {
                    // Mover al siguiente día
                    diaIndex += 1
                    horaActual = horarioInicio
                }
            }
        }
    }
}

func horasSeSolapan(_ inicio1: Int, _ inicio2: String, _ fin1: Int, _ fin2: String) -> Bool {
    let inicio2Minutos = horaAMinutos(inicio2)
    let fin2Minutos = horaAMinutos(fin2)

    return (inicio1 < fin2Minutos && fin1 > inicio2Minutos)
}

func minutosAHora(_ minutos: Int) -> String {
    let horas = minutos / 60
    let mins = minutos % 60
    return String(format: "%02d:%02d", horas, mins)
}

func horaAMinutos(_ hora: String) -> Int {
    let componentes = hora.split(separator: ":").map { Int($0) ?? 0 }
    return componentes[0] * 60 + componentes[1]
}
