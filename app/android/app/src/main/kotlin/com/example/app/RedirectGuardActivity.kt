package com.example.app

import android.app.Activity
import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log

class RedirectGuardActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val original: Uri? = intent?.data
        Log.e("RedirectGuard", "ORIGINAL uri=${original?.toString()} " +
                "| scheme=${original?.scheme} | ssp=${original?.schemeSpecificPart} " +
                "| isOpaque=${original?.isOpaque} | isHier=${original?.isHierarchical}")

        // Solo seguimos si de verdad viene a /oauthredirect
        if (original == null || original.host != "oauthredirect") {
            Log.e("RedirectGuard", "Ignorado: no es oauthredirect")
            finish(); return
        }

        // Si llega opaco (p. ej. com.clinic.patient:oauthredirect?...), normaliza a jerárquico.
        val fixed: Uri? = original?.let { u ->
            if (u.isOpaque) {
                val ssp = u.schemeSpecificPart ?: ""
                val normalized = Uri.parse("${u.scheme}://$ssp")
                Log.e("RedirectGuard", "NORMALIZED uri=$normalized")
                normalized
            } else u
        }

        // Reenvía explícitamente al receiver de AppAuth
        val forward = Intent().apply {
            component = ComponentName(
                this@RedirectGuardActivity,
                "net.openid.appauth.RedirectUriReceiverActivity"
            )
            data = fixed
            intent?.extras?.let { putExtras(it) }
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }

        startActivity(forward)
        finish()
    }
}
