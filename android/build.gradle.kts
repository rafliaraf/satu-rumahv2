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

// Force all plugin subprojects to compile against SDK 36
// Required because flutter_plugin_android_lifecycle now requires compileSdk >= 36
subprojects {
    val project = this
    fun applyCompileSdk() {
        val androidExt = project.extensions.findByName("android")
        if (androidExt is com.android.build.gradle.BaseExtension) {
            val currentSdk = androidExt.compileSdkVersion?.removePrefix("android-")?.toIntOrNull() ?: 0
            if (currentSdk < 36) {
                androidExt.compileSdkVersion(36)
            }
        }
    }

    if (project.state.executed) {
        applyCompileSdk()
    } else {
        project.afterEvaluate { applyCompileSdk() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
