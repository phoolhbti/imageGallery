<%@include file="/libs/foundation/global.jsp"%>
<%@page import="javax.jcr.Property"%>
<%@page import="javax.jcr.Value"%>
<%@page import="javax.jcr.nodetype.NodeType"%>
<%@page import="javax.jcr.NodeIterator"%>
<%@page import="javax.jcr.Node,org.apache.sling.api.resource.ResourceResolver,org.apache.sling.api.resource.Resource,org.apache.sling.api.resource.ValueMap"%>
<%@page import="java.util.*"%>
<%@page import="org.apache.sling.commons.json.JSONObject"%>
<%@page import="org.apache.sling.commons.json.JSONArray"%>
<cq:includeClientLib categories="mywebsite.components" />

        
        <script type="text/javascript">
            Cufon.replace('span,p,h1',{
                textShadow: '0px 0px 1px #ffffff'
            });
        </script>
        <style>
            span.reference{
                font-family:Arial;
                position:fixed;
                left:10px;
                bottom:10px;
                font-size:11px;
            }
            span.reference a{
                color:#aaa;
                text-decoration:none;
                margin-right:20px;
            }
            span.reference a:hover{
                color:#ddd;
            }
        </style>
    
        <div id="st_main" class="st_main">
            <img src="<cq:text property="mainImage"/>" alt="" class="st_preview" style="display:none;"/>
            <div class="st_overlay"></div>
            <h1><cq:text property="title" tagClass="text"/></h1>
            <div id="st_loading" class="st_loading"><span>Loading...</span></div>
            <ul id="st_nav" class="st_navigation">
            <%
               String nodeName=currentNode.getName();           
               String property[] = properties.get("./links",String[].class);
               StringBuffer result = new StringBuffer();               
                for (int i = 0; i < property.length; i++) {
                   result.append( property[i] );
                   result.append(",");
                }
                String mynewstring = result.toString();
                String jsonData="["+mynewstring+"]"; 
        if (jsonData != null) {     
            try {    
   
               JSONArray statesArray = new JSONArray(jsonData);
               for(int i = 0; i < statesArray.length(); i++) {  
               Map<String,String> stateItem = new HashMap<String,String>();          
              JSONObject jsonObject = statesArray.getJSONObject(i);          
              String text=jsonObject.getString("text"); 
             // out.println("<br>text"+text);         
              String url=jsonObject.getString("url"); 
             // out.println("<br>url "+url);
          %>
                <li class="album">
                    <span class="st_link"><%=text%><span class="st_arrow_down"></span></span>
                    <div class="st_wrapper st_thumbs_wrapper">
                        <div class="st_thumbs">
                        <%
                   ResourceResolver resourceResolver1 = slingRequest.getResourceResolver();
                   Resource campaignResource = resourceResolver1.getResource(url);
                  Node imageRootNode = campaignResource.adaptTo(Node.class);
                   if(imageRootNode.hasNodes()){
                   NodeIterator nodeit=imageRootNode.getNodes();
                  // int k=0;&& k<5
                   while(nodeit.hasNext()){
                      Node childNode= nodeit.nextNode(); 
                      NodeType damnodtype= childNode.getPrimaryNodeType() ;
                   if(damnodtype.isNodeType("dam:Asset") ){
                   String imagepath=childNode.getPath();
                 //  out.println("childNode"+childNode.getPath());
                   %>                  
                  <img src="<%=imagepath%>/jcr:content/renditions/cq5dam.thumbnail.140.100.png" alt="<%=imagepath%>">
                   <%
                   //k++;
                   }
                   }
                  }
                                      %> 
                            
                        </div>
                    </div>
                </li>
                <%
                }             
  } catch (Exception e) {
    log.error("Invalid JSON:" + jsonData);     } 
} 
   %>
                <li>
                    <span class="st_link"><cq:text property="aboutusTitle"/><span class="st_arrow_down"></span></span>
                    <div class="st_about st_thumbs_wrapper">
                        <div class="st_subcontent">
                            <cq:text property="text" tagClass="text"/>
                        </div>
                    </div>
                </li>
            </ul>
        </div>
         
        <!-- The JavaScript -->
        <script type="text/javascript">
            $(function() {
                //the loading image
                var $loader     = $('#st_loading');
                //the ul element 
                var $list       = $('#st_nav');
                //the current image being shown
                var $currImage  = $('#st_main').children('img:first');
                 
                //let's load the current image 
                //and just then display the navigation menu
                $('<img>').load(function(){
                    $loader.hide();
                    $currImage.fadeIn(3000);
                    //slide out the menu
                    setTimeout(function(){
                        $list.animate({'left':'0px'},500);
                    },
                    1000);
                }).attr('src',$currImage.attr('src'));
                 
                //calculates the width of the div element 
                //where the thumbs are going to be displayed
                buildThumbs();
                 
                function buildThumbs(){
                    $list.children('li.album').each(function(){
                        var $elem           = $(this);
                        var $thumbs_wrapper = $elem.find('.st_thumbs_wrapper');
                        var $thumbs         = $thumbs_wrapper.children(':first');
                        //each thumb has 180px and we add 3 of margin
                        var finalW          = $thumbs.find('img').length * 183;
                        $thumbs.css('width',finalW + 'px');
                        //make this element scrollable
                        makeScrollable($thumbs_wrapper,$thumbs);
                    });
                }
                 
                //clicking on the menu items (up and down arrow)
                //makes the thumbs div appear, and hides the current 
                //opened menu (if any)
                $list.find('.st_arrow_down').live('click',function(){
                    var $this = $(this);
                    hideThumbs();
                    $this.addClass('st_arrow_up').removeClass('st_arrow_down');
                    var $elem = $this.closest('li');
                    $elem.addClass('current').animate({'height':'170px'},200);
                    var $thumbs_wrapper = $this.parent().next();
                    $thumbs_wrapper.show(200);
                });
                $list.find('.st_arrow_up').live('click',function(){
                    var $this = $(this);
                    $this.addClass('st_arrow_down').removeClass('st_arrow_up');
                    hideThumbs();
                });
                 
                //clicking on a thumb, replaces the large image
                $list.find('.st_thumbs img').bind('click',function(){
                    var $this = $(this);
                    $loader.show();
                    $('<img class="st_preview"/>').load(function(){
                        var $this = $(this);
                        var $currImage = $('#st_main').children('img:first');
                        $this.insertBefore($currImage);
                        $loader.hide();
                        $currImage.fadeOut(2000,function(){
                            $(this).remove();
                        });
                    }).attr('src',$this.attr('alt'));
                }).bind('mouseenter',function(){
                    $(this).stop().animate({'opacity':'1'});
                }).bind('mouseleave',function(){
                    $(this).stop().animate({'opacity':'0.7'});
                });
                 
                //function to hide the current opened menu
                function hideThumbs(){
                    $list.find('li.current')
                         .animate({'height':'50px'},400,function(){
                            $(this).removeClass('current');
                         })
                         .find('.st_thumbs_wrapper')
                         .hide(200)
                         .andSelf()
                         .find('.st_link span')
                         .addClass('st_arrow_down')
                         .removeClass('st_arrow_up');
                }
 
                //makes the thumbs div scrollable
                //on mouse move the div scrolls automatically
                function makeScrollable($outer, $inner){
                    var extra           = 800;
                    //Get menu width
                    var divWidth = $outer.width();
                    //Remove scrollbars
                    $outer.css({
                        overflow: 'hidden'
                    });
                    //Find last image in container
                    var lastElem = $inner.find('img:last');
                    $outer.scrollLeft(0);
                    //When user move mouse over menu
                    $outer.unbind('mousemove').bind('mousemove',function(e){
                        var containerWidth = lastElem[0].offsetLeft + lastElem.outerWidth() + 2*extra;
                        var left = (e.pageX - $outer.offset().left) * (containerWidth-divWidth) / divWidth - extra;
                        $outer.scrollLeft(left);
                    });
                }
            });
        </script>