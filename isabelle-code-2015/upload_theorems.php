<?php

// directory where local theory output lives. e.g. output
$theory_dir = $argv[1];

// url prefix for domain and dir prefix: e.g. theorymine.co.uk/vtp2, 
// or localhost:8888/theorymine.co.uk
$url_prefix = $argv[2];

// value of pass of post field for ?go=import_theorems e.g. vtppassU1 
$url_pass = $argv[3]; 

// empty for none, or LOGIN:PASS e.g. vtp:ca3nyH9ewgHR
$httpauth = $argv[4]; 

if($argv[1] == "--help" or $argv[1] == "") {
  print("USAGE: php " . $argv[0] . " THEORY_DIR URL_PREFIX PASSWORD [HTTP_AUTH]\n NO THEOREMS HAVE BEEN UPLOADED \n");
} else {
  print("theory_dir [1] = " . $theory_dir . "\n");
  print("url_prefix [2] = " . $url_prefix . "\n");
  
  chdir($theory_dir);
  $local_ls = scandir(".");
  foreach($local_ls as $n) {
    if(preg_match('/^T_\\d*$/',$n)){
      print("datatype/dir_name: " . $n . "\n");
      $dir_ls = scandir($n);
      foreach($dir_ls as $thry_name) {
        $filename = $n . '/' . $thry_name;
        print("considering: $filename \n");
        if(is_file($filename) and   
            preg_match('/\/output-thy_\\d*.php$/',$filename)) {
          print($filename . " : uploading... \n");
          //if($handle = fopen($thry_file, 'r')) 
          //  $contents = fread($handle, filesize($thry_file));
          //  fclose($handle);
          $ch = curl_init();
          
          $data = array(
            'act' => 'upload',
            'thy_name_prefix' => $n,
            'theorems_file' => '@' . $filename, 
            'pass' => $url_pass
          );
          
          curl_setopt($ch, CURLOPT_URL, 'http://' . $url_prefix . '/?go=import_theorems');
          //curl_setopt($ch, CURLOPT_URL, '?go=import_theorems');
          // 
          if($httpauth != null){ 
            curl_setopt($ch, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
            curl_setopt($ch, CURLOPT_USERPWD, $httpauth);
          }
          curl_setopt($ch, CURLOPT_POST, 1);
          curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
          //curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1) ;
          curl_setopt($ch, CURLOPT_USERAGENT, "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13");

          $fp = fopen('php_upload_log.txt', 'w');
          curl_setopt($ch, CURLOPT_FILE, $fp);
          
          curl_exec($ch);
          $error_no = curl_errno($ch);
          curl_close($ch);
          fclose($fp);

          if ($error_no == 0) {
            $error = $filename . " : File uploaded succesfully \n";
          } else {
            $error = $filename . " : file upload error: " . $error_no . "\n";
          }
          print($error);
        }
      }
    } else {
      print("ignored name: " . $n . "\n");
    }
  }
}
?>
