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
echo '<body>';
echo '

';  #Enter any HTML code you want displayed before the log between the single quotes.  This could be useful for a header.

$file=file_get_contents("http://example.com/logs/channel.htm"); #Change this to the path of the raw output
$file=explode("\n", $file);
foreach ($file as $line){
        if($line==""){
        } else {
                $line=explode(' ', $line, 3);
                echo '<span class="timestamp">' . $line['0'] . '</span>';
                $nick=explode(">", $line['1']);
                $nick['0']=str_replace("\x0302", '<span class="nick" style="color:navy;">', $nick['0']);
                $nick['0']=str_replace("\x0303", '<span class="nick" style="color:green;">', $nick['0']);
                $nick['0']=str_replace("\x0304", '<span class="nick" style="color:red;">', $nick['0']);
                $nick['0']=str_replace("\x0306", '<span class="nick" style="color:purple;">', $nick['0']);
                $nick['0']=str_replace("\x0310", '<span class="nick" style="color:teal;">', $nick['0']);
                $nick['0']=str_replace("\x0313", '<span class="nick" style="color:fuchsia;">', $nick['0']);
                $line['2']=htmlentities($line['2']);
                $line['2']=str_replace("\x0301", '</span><span class="body" style="color:black;">', $line['2']);
                $line['2']=str_replace("\x0302", '</span><span class="body" style="color:navy;">', $line['2']);
                $line['2']=str_replace("\x032", '</span><span class="body" style="color:navy;">', $line['2']);
                $line['2']=str_replace("\x0303", '</span><span class="body" style="color:green;">', $line['2']);
                $line['2']=str_replace("\x033", '</span><span class="body" style="color:green;">', $line['2']);
                $line['2']=str_replace("\x0304", '</span><span class="body" style="color:red;">', $line['2']);
                $line['2']=str_replace("\x034", '</span><span class="body" style="color:red;">', $line['2']);
                $line['2']=str_replace("\x0305", '</span><span class="body" style="color:maroon;">', $line['2']);
                $line['2']=str_replace("\x035", '</span><span class="body" style="color:maroon;">', $line['2']);
                $line['2']=str_replace("\x0306", '</span><span class="body" style="color:purple;">', $line['2']);
                $line['2']=str_replace("\x036", '</span><span class="body" style="color:purple;">', $line['2']);
                $line['2']=str_replace("\x0307", '</span><span class="body" style="color:orangered;">', $line['2']);
                $line['2']=str_replace("\x037", '</span><span class="body" style="color:orangered;">', $line['2']);
                $line['2']=str_replace("\x0308", '</span><span class="body" style="color:yellow;">', $line['2']);
                $line['2']=str_replace("\x038", '</span><span class="body" style="color:yellow;">', $line['2']);
                $line['2']=str_replace("\x0309", '</span><span class="body" style="color:lime;">', $line['2']);
                $line['2']=str_replace("\x039", '</span><span class="body" style="color:lime;">', $line['2']);
                $line['2']=str_replace("\x0310", '</span><span class="body" style="color:teal;">', $line['2']);
                $line['2']=str_replace("\x0311", '</span><span class="body" style="color:cyan;">', $line['2']);
                $line['2']=str_replace("\x0312", '</span><span class="body" style="color:royalblue;">', $line['2']);
                $line['2']=str_replace("\x0313", '</span><span class="body" style="color:fuschia;">', $line['2']);
                $line['2']=str_replace("\x0314", '</span><span class="body" style="color:grey;">', $line['2']);
                $line['2']=str_replace("\x0315", '</span><span class="body" style="color:silver;">', $line['2']);
                $line['2']=str_replace("\x031", '</span><span class="body" style="color:black;">', $line['2']);
                $line['2']=str_replace("\u000F", '</span><span class="body" style="color:black;">', $line['2']);
                $line['2']=str_replace("\x03", '</span><span class="body" style="color:black;">', $line['2']);

                if(substr($line['1'], -1, 1)==">"){
                        echo " " . $nick['0'] . '</span>>';

                        echo " " . $line['2'] . '</span>';
                } else {
                        echo " " . $nick['0'] . " " . $line['2'] . '</span>';
                }
        echo "<br>\n";
        }
}
?>
