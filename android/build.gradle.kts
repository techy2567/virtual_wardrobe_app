
buildscript {
    repositories {
        google()  // Ensure Google's Maven repo is included
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.4")  // Your existing AGP version
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")  // Kotlin plugin
        classpath("com.google.gms:google-services:4.3.15")  // Add this line
    }
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
