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
    project.pluginManager.withPlugin("com.android.library") {
        val androidExt = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        if (androidExt != null && androidExt.namespace == null) {
            val defaultNamespace = project.group.toString()
            if (defaultNamespace.isNotEmpty() && defaultNamespace != "unspecified") {
                androidExt.namespace = defaultNamespace
            } else {
                androidExt.namespace = "com.example." + project.name.replace("-", "_")
            }
        }
    }
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
subprojects {
    project.pluginManager.withPlugin("kotlin-android") {
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
    }
    project.pluginManager.withPlugin("com.android.library") {
        val androidExt = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        androidExt?.compileOptions {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }
    }
}
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
