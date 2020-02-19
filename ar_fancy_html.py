#!/usr/bin/python3

# This is a supplement script to AutoRecon. I wanted to include
# a Results page in HTML with a clickable menu.

import os

rootdir = os.path.dirname(os.path.realpath(__file__))
resdir = os.path.abspath(os.path.join(rootdir, 'results'))

# IF dir doesnt exist make it.
#os.makedirs(scandir, exist_ok=True)

html_head = """
<!DOCTYPE html">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

    <title>Results</title>
    
    <meta name="viewport" content="width=device-width">
    

                <style>
        body, html {
            height:100%;
            font-family:Lucida Console,Lucida Sans Typewriter,monaco,Bitstream Vera Sans Mono,monospace;
            line-height:1.5em;
            font-weight:300;
            background-color:#FAFAFA;
            text-rendering:geometricPrecision;
            font-size: 12px;
            margin:0;
            padding:0;
        }
        .wrapper {
            height:100%;
            position:relative;
        }
        #navigation {
            background-color:#F3F3F3;
            display:inline-block;
            border-right:1px solid #EAEAEA;
            padding-right:65px;
            padding-top:65px;
            padding-left:25px;
            position:relative;
            float:left;
            min-height:100%;
        }
        #navigation ul {
            margin-top:0;
            margin-bottom:0;
            padding-left:40px;
        }
        #navigation li {
            list-style-type:none;
        }
        #navigation a {
            text-decoration:none;
            color:gray;
        }
        #navigation strong {
            color:#4E9A06;
            font-weight:400;
        }
        #navigation a:hover {
            text-decoration:underline;
        }
        #content {
            float:left;
            display:inline-block;
            position:absolute;
            max-width:960px;
            padding:65px;
        }
        </style>
                </head>
                <body> 
                    <div class="wrapper">
                     <div id="navigation"> 
                        <ul>
"""

html_foot = """
                        </ul>
                     </div>

                     <pre><div id="content"></div></pre>

                    </div> 
                    <![if !IE]>
                <!-- comment out for IE since it spams the user with warnings -->
                <script type='text/javascript' src='http://code.jquery.com/jquery-1.7.1.js'></script>
                <script type='text/javascript'>
                 $(window).load(function(){$("#navigation").height( $("#content").height()+65 );});
                </script>

                <script type="text/javascript"> 
                    $(document).ready(function(){
                        // your on click function here
                        $('a').click(function(){
                         $('#content').load($(this).attr('href'));
                         return false;
                          });
                        $('#dyn_sel').on('change', function() {
                          var url = $(this).val(); //get selected value
                            if (url){
                                window.location = url; // redirect
                            }
                            return false;
                         }); 

                    });
                </script>
                <![endif]>
                 </body>
                </html>
"""
# Lets find our target directories and create
# a <select> list out of them.
select = ['<select id="dyn_sel"><option value="" selected>Host</option>']

for dir in sorted(os.listdir(resdir)):
    select.append("<option value='../" + dir + "/results.html'>" + dir + "</option>")

select.append("</select>")
options = ''.join(select)

# Lets find our target directories first.
for dir in os.listdir(resdir):
    tardir = os.path.join(resdir, dir)
    # print directories only
    #if os.path.isdir(os.path.join(resdir, dir)):
    if os.path.isdir(tardir):
        #print(tardirs)
        # change directory here.
        os.chdir(tardir)
        with open('results.html', 'w') as html:
            # write out our html head section first
            html.write(html_head)
            html.write("<li><b>Select a:</b> " + options + "</li>" + "\n")
            html.write("<li><b>Menu for: " + dir + "</b></li>" + "\n")
            for scans in os.listdir(tardir):
                # list the scans directories inside target dirs
                # do not list files
                if os.path.isfile(scans):
                    continue
                scandir = os.path.join(tardir, scans)
                #print(scandir)
                for files in os.listdir(scandir):
                    filename = os.fsdecode(files)
                    # skip subdirectories
                    subdir = os.path.join(scandir, filename)
                    if os.path.isdir(subdir):
                        continue
                    #print(filename)
                    # write out our html links to reports
                    html.write("<li><a href='./scans/" + filename + "'>" + filename + "</a></li>" + "\n")
                    # write out our html footer
                html.write(html_foot)
        html.close()


