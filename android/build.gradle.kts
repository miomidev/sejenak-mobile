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

subprojects {
    fun applyNamespace() {
        val android = extensions.findByName("android")
        if (android != null) {
            val getNamespace = android.javaClass.methods.find { it.name == "getNamespace" }
            val setNamespace = android.javaClass.methods.find { it.name == "setNamespace" && it.parameterTypes.size == 1 }
            if (getNamespace != null && setNamespace != null) {
                if (getNamespace.invoke(android) == null) {
                    val pkgName = "com.flutter.plugins.${project.name.replace('-', '_')}"
                    setNamespace.invoke(android, pkgName)
                }
            }
        }
    }

    if (state.executed) {
        applyNamespace()
    } else {
        afterEvaluate {
            applyNamespace()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
