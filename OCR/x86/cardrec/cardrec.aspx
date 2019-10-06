<%@ Page Language="C#" MasterPageFile="Site.master" AutoEventWireup="true" EnableEventValidation="false" ValidateRequest="false" EnableViewStateMac="false"%>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
</asp:Content>

<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <h1><center>Card Scanner</center></h1>
    <div class="container">
        <div class="col-md-6">
            <h3>Input Image</h3>
            <form method="POST" action="proc.aspx" enctype="multipart/form-data" target="_result">
                <div class="form-group">
                    <div style="text-align: center;border:1px solid green; width: 100%; height: 300px;">
                        <img id="imgCard" name="imgCard" style="max-width: 100%; max-height: 100%;" />
                    </div>
                    <div class="input-group input-file" name="fileToUpload">
		                <span class="input-group-btn">
        	                <button class="btn btn-default btn-choose" type="button">Choose</button>
    	                </span>
                        <input type="text" class="form-control" id ="txtImgPath"/>
                    </div>
                </div>
                <div class="form-group">
                    <label for="card_type">Card Type:</label>
                    <select class="form-control" id="card_type" name="card_type">
                        <option>Passport & ID Card (MRZ)</option>
			            <option>PAN CARD INDIA</option>
                        <option>AADHAR CARD INDIA (Front)</option>
			            <option>AADHAR CARD INDIA (Back)</option>   
                        <!--option>INDIA PASSPORT (Back)</!--option--> 
                        <!--option>FACE DETECT</!--option--> 
                    </select>
                </div>
                <!-- COMPONENT END -->
                <div class="form-group">
                    <button type="submit" id="btnRecognize" name="btnRecognize" class="btn btn-primary pull-right">Recognize</button>
                </div>
                <br />
                <!--
                <label for="card_type">Camera View:</label>
                <asp:Panel ID="pnl_WebCam" runat="server" BorderColor="#CCCCCC" BorderStyle="Groove"
                                                 BorderWidth="3px" BackColor="#CCCCCC">
                    <div class="camera">
                        <video id="video">Video stream not available.</video>
                        <div style="display:none">
                            <canvas id="canvas">
                            </canvas>
                            <div class="output">
                                <img id="photo" alt="The screen capture will appear in this box." src="" />
                            </div>
                        </div>
                    </div>            
                </asp:Panel>
                <button type="button" id="startbutton" style="display:none"></button>
                <button type="button" id="btnTakePicture" class="btn btn-primary pull-right" onclick="SaveImg();">Take Picture</button> 
                <br />
                -->
            </form>
        </div>
        <iframe id="_result" name="_result" style="visibility:hidden;height:0;"></iframe>
        <div class="col-md-6" id="result_view" style="visibility: hidden;">
            <h3>Result</h3>
            <div id="image_view" style="visibility: hidden;">
        	    <img id="im_face" name="im_face" style="max-width: 100%; max-height: 100%;">
            </div>
            <div id="result_content"></div>
            <div id="card_view" style="visibility: hidden;">
        	    <img id="im_card" name="im_card" style="max-width: 100%; max-height: 100%;">
            </div>
        </div>
    </div>
</asp:Content>

