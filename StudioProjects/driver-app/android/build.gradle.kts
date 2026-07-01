allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// These properties fix the NullPointerException in legacy plugins (like flutter_secure_storage)
// by ensuring they are available in the project's extra properties bag.
project.extensions.extraProperties.set("minSdkVersion", 23)
project.extensions.extraProperties.set("targetSdkVersion", 35)
project.extensions.extraProperties.set("compileSdkVersion", 35)

// Secondary fallback with 'flutter.' prefix as some plugins specifically look for these
project.extensions.extraProperties.set("flutter.minSdkVersion", 23)
project.extensions.extraProperties.set("flutter.targetSdkVersion", 35)
project.extensions.extraProperties.set("flutter.compileSdkVersion", 35)

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
