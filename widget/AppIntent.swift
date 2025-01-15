//
//  AppIntent.swift
//  widget
//
//  Created by Jose Decena on 19/12/24.
//

import WidgetKit
import AppIntents


// Configuración del Intent para el widget
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }
}


