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
