<%@include file="/libs/foundation/global.jsp"%>
<%@page import="java.util.*,
                javax.jcr.Node,
                javax.jcr.NodeIterator,
                javax.jcr.nodetype.NodeType,
                javax.jcr.Property,
                javax.jcr.Value,
                org.apache.sling.api.resource.ResourceResolver,
                org.apache.sling.api.resource.Resource,
                org.apache.sling.commons.json.JSONObject,
                org.apache.sling.commons.json.JSONArray,
                org.apache.sling.api.resource.ValueMap"%>
                
<cq:includeClientLib categories="mywebsite.imagegallery" />
        <script type="text/javascript">
            Cufon.replace('span,p,h1',{
                textShadow: '0px 0px 1px #ffffff'
            });
        </script>
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
                for (int i = 0; currentNode.hasProperty("./links")&&(i < property.length); i++) {
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
         
        
