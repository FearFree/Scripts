<?php
echo '<html><head><style>
body {
font-family: "Courier New",
            Consolas,
            "Bitstream Vera Sans Mono",
            "DejaVu Sans Mono",
            monospace;
}
</style></head>' . "\n";
 
echo '<body>List of all logged channels: <br>';
$dir="/path/to/log/files/";
$files=scandir($dir);
foreach($files as $name){
        if(substr($name, 0, 1)=="."){ #Comment this and uncomment below to show hidden files
#       if($name=="." OR $name==".."){ #Uncomment this, and comment above to show hidden files
       } else {
                $name=pathinfo($name);
                echo '<a href="http://example.com/path/to' . $name['basename'] . '">' . $name['filename'] .  "<br>";
        }
}
echo '</body></html>';
?>
