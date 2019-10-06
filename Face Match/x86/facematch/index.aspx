<%@ Page Language="C#" MasterPageFile="Site.master" AutoEventWireup="true" EnableEventValidation="false" ValidateRequest="false" EnableViewStateMac="false"%>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
</asp:Content>

<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <h1><center>Face Match</center></h1>
    <div class="container">
        <form id = "face-form">
            <div class="col-md-6">
                <div class="form-group">
                    <div style="text-align: center;border:1px solid green; width: 100%; height: 300px;">
                        <img id="imgLeft" name="imgLeft" style="max-width: 80%; max-height: 100%;" />
                    </div>
                    <div class="input-group input-file" name="fileLeft">
		                <span class="input-group-btn">
        	                <button class="btn btn-primary pull-right btn-choose-left" type="button">Choose...</button>
    	                </span>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="form-group">
                    <div style="text-align: center;border:1px solid green; width: 100%; height: 300px;">
                        <img id="imgRight" name="imgRight" style="max-width: 80%; max-height: 100%;" />
                    </div>
                    <div class="input-group input-file" name="fileRight">
		                <span class="input-group-btn">
        	                <button class="btn btn-primary pull-right btn-choose-right" type="button">Choose...</button>
    	                </span>
                    </div>
                </div>
            </div>
        </form>
    </div>
    <h3><center><span id="score-label">0 %</span></center></h3>
</asp:Content>
