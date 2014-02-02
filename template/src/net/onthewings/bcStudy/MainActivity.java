package ::APP_PACKAGE::;

public class MainActivity extends org.haxe.lime.GameActivity {
	static public String getSystemVersion() {
		return android.os.Build.VERSION.RELEASE;
	}
	
	static public String getHardwareModel() {
		return android.os.Build.MODEL;
	}
}

