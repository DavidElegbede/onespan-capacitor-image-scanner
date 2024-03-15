package com.vasco.plugins.qrcodescanner;
import static android.app.Activity.RESULT_OK;
import static android.app.Activity.RESULT_CANCELED;
import android.os.Bundle;
import android.content.Context;
import android.Manifest;
import com.getcapacitor.Logger;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import android.util.Log;
import android.content.Intent;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PermissionState;
import com.getcapacitor.annotation.Permission;
import com.getcapacitor.annotation.PermissionCallback;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import androidx.activity.result.ActivityResult;
import com.getcapacitor.annotation.ActivityCallback;

import com.vasco.digipass.sdk.utils.qrcodescanner.QRCodeScannerSDKConstants;
import com.vasco.digipass.sdk.utils.qrcodescanner.sample.QrCodeScannerSampleActivity;
import com.vasco.digipass.sdk.utils.qrcodescanner.QRCodeScannerSDKActivity;
import com.vasco.digipass.sdk.utils.qrcodescanner.QRCodeScannerSDKException;
import com.vasco.digipass.sdk.utils.qrcodescanner.sample.SystemCameraActivity;

@CapacitorPlugin(
    name = "QRCodeScanner",
    permissions = {
        @Permission(
            alias = "camera",
            strings = { Manifest.permission.CAMERA }
        ),
        @Permission(
            alias = "vibrate",
            strings = { Manifest.permission.VIBRATE }
        )
    }
)
  

public class QRCodeScannerPlugin extends Plugin {
    static final String CAMERA = "camera";
    static final String TAG = "ScanLOG";
     static final int ACCESS_CAMERA_REQUEST_CODE = 1;

    /** Request code used for Camera's activity results. */
    private static final int CAMERA_ACTVITY_REQUEST_CODE = 2;

    private static final String PERMISSION_DENIED_ERROR_CAMERA = "User denied access to camera";
    private QRCodeScanner implementation = new QRCodeScanner();
    QrCodeScannerSampleActivity systemCameraActivity = new QrCodeScannerSampleActivity();


  @Override
  public void load() {
      // Called when the plugin is first loaded

  }
   


    @PluginMethod
    public void scan(PluginCall call){
        Log.d(TAG, "scanscan outer");
        if (getPermissionState("camera") != PermissionState.GRANTED) {
                requestPermissionForAlias("camera", call, "cameraPermsCallback");
        }else{
            opencamera(call); 
        }
    }

    @PermissionCallback
    private void cameraPermsCallback(PluginCall call) {
        Log.d(TAG, "cameraPermsCallback outer");
        if (getPermissionState("camera") == PermissionState.GRANTED) {
            Log.d(TAG, "cameraPermsCallback if");
            JSObject ret = new JSObject();
            ret.put("value", "Got the permission");
            call.resolve(ret);
            Context context = getContext();
            opencamera(call);
        } else {
            Log.d(TAG, "cameraPermsCallback else");
            call.reject("Permission is required to access the camera");
        }
    }

    public void opencamera(PluginCall call) {
        String extra_vibrate = call.getString("extra_vibrate","true");
        String extra_code_type = call.getString("extra_code_type","3");
        String extra_scanner_overlay = call.getString("extra_scanner_overlay","true");
        String extra_scanner_overlay_color = call.getString("extra_scanner_overlay_color","true");
        Log.d(TAG,"EXTRA_VIBRATE" + extra_vibrate);
        Log.d(TAG,"EXTRA_CODE_TYPE" + extra_code_type);
        Log.d(TAG,"EXTRA_SCANNER_OVERLAY" + extra_scanner_overlay);
        Log.d(TAG,"EXTRA_SCANNER_OVERLAY_COLOR" + extra_scanner_overlay_color);

        Intent intent = new Intent(getContext(), QRCodeScannerSDKActivity.class);
        intent.putExtra(QRCodeScannerSDKConstants.EXTRA_VIBRATE, Boolean.valueOf(extra_vibrate));
        intent.putExtra(
                QRCodeScannerSDKConstants.EXTRA_CODE_TYPE,
                QRCodeScannerSDKConstants.QR_CODE + QRCodeScannerSDKConstants.CRONTO_CODE);
        intent.putExtra(QRCodeScannerSDKConstants.EXTRA_SCANNER_OVERLAY, Boolean.valueOf(extra_scanner_overlay));
        intent.putExtra(QRCodeScannerSDKConstants.EXTRA_SCANNER_OVERLAY_COLOR, Boolean.valueOf(extra_scanner_overlay_color));
        startActivityForResult(call, intent, "CameraScanningResult");
    }

    @ActivityCallback
    private void CameraScanningResult(PluginCall call, ActivityResult result) {
        Log.d(TAG,"activity result" + result);
        Intent data = result.getData();
        Log.d(TAG,"RESULTCodddd" + result.getResultCode());
        Log.d(TAG,"RESULTRESULT_CANCELED" + RESULT_CANCELED);
        Log.d(TAG,"RESULTRESULT_OK" + RESULT_OK);
        if (result.getResultCode() == RESULT_OK) {
              Log.d(TAG,"RESULT_OK" + result.getResultCode());
//            Bundle extras = data.getExtras();
              Log.d(TAG,"RESULT_OK" + result.getData());
//            String extrasString = extras != null ? extras.toString() : "No extras";
             int scannedImageFormat =
                      data.getIntExtra(QRCodeScannerSDKConstants.OUTPUT_CODE_TYPE, 0);
              String scannedImageData = data.getStringExtra(QRCodeScannerSDKConstants.OUTPUT_RESULT);

              String format =
                      scannedImageFormat == QRCodeScannerSDKConstants.CRONTO_CODE
                              ? "Cronto Sign"
                              : "QR Code";
              Log.d(TAG, "Scanned image data = " + scannedImageData);
              Log.d(TAG, "Scanned image format = " + format);
              JSObject ret = new JSObject();
              String scannedDataInfo = bridge
                      .getActivity()
                      .getResources()
                      .getString(com.vasco.digipass.sdk.utils.qrcodescanner.sample.R.string.scanned_data_info, format);

              ret.put("imageData", scannedImageData);
              ret.put("imageInfo", scannedDataInfo);
            // Resolve the Capacitor call with the result data
            call.resolve(ret);

        } else if(result.getResultCode() == RESULT_CANCELED) {
            Log.d(TAG,"in cancalled resultData" + RESULT_CANCELED);
              JSObject ret = new JSObject();
              ret.put("imageInfo", RESULT_CANCELED);
              call.resolve(ret);
          } else if(result.getResultCode() == QRCodeScannerSDKConstants.RESULT_ERROR){
              QRCodeScannerSDKException exception =
                      (QRCodeScannerSDKException)
                              data.getSerializableExtra(QRCodeScannerSDKConstants.OUTPUT_EXCEPTION);
              call.resolve(new JSObject().put("result", "There is an error occured"));
        }
    }
}
