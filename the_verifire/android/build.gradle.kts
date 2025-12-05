// This is the project-level build.gradle.kts file. (Kotlin DSL)

// Define the Kotlin version using the `extra` properties, which is the Kotlin equivalent of Groovy's `ext` block.
// This block must be outside the `buildscript` block for project-level variables.
val kotlinVersion by extra("1.8.20")

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // 🛑 FIX 1: Add the mandatory Android Gradle Plugin (AGP) classpath
        classpath("com.android.tools.build:gradle:8.0.0") 

        // Use the defined variable
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.20")
        
        // 🛑 FIX 2: The 'com.google.gms:google-services' classpath has been removed/omitted from here
        // to prevent conflicts with the 'plugins' block below.
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

plugins {
    // This is the correct location and syntax for declaring the plugin version 
    // in KTS project-level files (`apply false` is mandatory here).
    id("com.google.gms.google-services") version "4.3.15" apply false
}