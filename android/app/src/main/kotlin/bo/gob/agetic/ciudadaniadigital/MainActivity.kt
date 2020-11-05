package bo.gob.agetic.ciudadaniadigital

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    /*public override fun onPause() {
        window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE);
        super.onPause()
    }*/

    public override fun onResume() {
        super.onResume()
        // window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        // window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
