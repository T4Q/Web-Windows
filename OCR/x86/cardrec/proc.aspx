<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="proc.aspx.cs" Inherits="cardrec.proc" %>

<%
    string message = "";
    try
    {
        HttpPostedFile imgCard = null;
        var card_type = Request.Form.GetValues("card_type");

        foreach (string file in Request.Files)
        {
            var postedFile = Request.Files[file];
            if (postedFile != null && postedFile.ContentLength > 0)
            {
                int MaxContentLength = 1024 * 1024 * 50; //Size = 50 MB
                IList<string> AllowedFileExtensions = new List<string> { ".jpg", ".gif", ".png", ".jpeg"};
                var ext = postedFile.FileName.Substring(postedFile.FileName.LastIndexOf('.'));
                var extension = ext.ToLower();

                if (!AllowedFileExtensions.Contains(extension))
                {
                    message = string.Format("<text>Please Upload image of type .jpg, .jpeg, .gif, .png.</text>");
                    Response.Write(message);
                    return;
                }
                else if (postedFile.ContentLength > MaxContentLength)
                {
                    message = string.Format("<text>Please Upload a file upto 50 mb.</text>");
                    Response.Write(message);
                    return;
                }
                else
                {
                    var filePath = HttpContext.Current.Server.MapPath("~/temp/" + postedFile.FileName + extension);
                    //postedFile.SaveAs(filePath);
                    imgCard = postedFile;
                    break;
                }
            }
        }

        if (imgCard == null || imgCard.ContentLength == 0)
        {
            Response.Write("<text>Image upload failed.</text>");
            return;
        }

        byte[] imgBuf = new byte[imgCard.ContentLength];
        int nBuf = imgCard.InputStream.Read(imgBuf, 0, imgCard.ContentLength);

        string dic = HttpContext.Current.Server.MapPath("~/db/mMQDF_f_Passport_bottom_Gray.dic");
        string dic1 = HttpContext.Current.Server.MapPath("~/db/mMQDF_f_Passport_bottom.dic");
        string tdata = HttpContext.Current.Server.MapPath("~/db/eng.dat");
        string license = HttpContext.Current.Server.MapPath("~/db/key.license");

        if (!System.IO.File.Exists(license))
        {
            Response.Write("<text>Could not find file './db/key.license' <br /> License Key Missing</text>");
            return;
        }

        System.IO.Stream dic_is = OpenFile(dic);
        System.IO.Stream dic1_is = OpenFile(dic1);
        System.IO.Stream tdata_is = OpenFile(tdata);
        System.IO.Stream license_is = OpenFile(license);

        byte[] bydic = new byte[dic_is.Length];
        byte[] bydic1 = new byte[dic1_is.Length];
        byte[] bytdata = new byte[tdata_is.Length];
        byte[] bylicense = new byte[license_is.Length];

        dic_is.Read(bydic, 0, (int)dic_is.Length);
        dic1_is.Read(bydic1, 0, (int)dic1_is.Length);
        tdata_is.Read(bytdata, 0, (int)tdata_is.Length);
        license_is.Read(bylicense, 0, (int)license_is.Length);

        dic_is.Close();
        dic1_is.Close();
        tdata_is.Close();
        license_is.Close();

        int nCardType = -1;
        if (card_type[0].Equals("PAN CARD INDIA"))
            nCardType = 0;
        else if (card_type[0].Equals("AADHAR CARD INDIA (Front)"))
            nCardType = 1;
        else if (card_type[0].Equals("AADHAR CARD INDIA (Back)"))
            nCardType = 1;
        else if (card_type[0].Equals("Passport & ID Card (MRZ)"))
            nCardType = 2;
        else if (card_type[0].Equals("INDIA PASSPORT (Back)"))
            nCardType = 6;
        else if (card_type[0].Equals("FACE DETECT"))
            nCardType = 100;

        IntPtr hHandle = initCardEngine(nCardType);
        if (hHandle == null)
        {
            Response.Write("<text>Failed to initalize the engine.</text>");
            return;
        }

        //////////////////
        //face
        ///////////////////
        if (nCardType == 100)
        {
            int nResult = 0;
            IntPtr ptrface = doFaceDetect(hHandle, imgBuf, imgBuf.Length, ref nResult);

            byte[] byface;
            if (ptrface != null)
            {
                Response.Write("<text></text>");
                if (nResult > 0)
                {
                    byface = new byte[nResult];
                    System.Runtime.InteropServices.Marshal.Copy(ptrface, byface, 0, nResult);
                    Response.Write("<face>" + "data:image/jpg;base64," + Convert.ToBase64String(byface) + "</face>");
                }
                else
                {
                    Response.Write("<face></face>");
                }
                if (imgBuf != null)
                    Response.Write("<card>" + "data:image/jpg;base64," + Convert.ToBase64String(imgBuf) + "</card>");

                byface = null;
                imgBuf = null;
                GC.Collect();
                return;
            }
        }

        int nDev = 0;
        IntPtr ptrDev = getDevInfo(hHandle, ref nDev);
        string strDev = System.Runtime.InteropServices.Marshal.PtrToStringAnsi(ptrDev, nDev);

        int nRet = loadDB(hHandle, bydic, bydic.Length, bydic1, bydic1.Length, bytdata, bytdata.Length, bylicense, bylicense.Length);
        bydic = bydic1 = bytdata = bylicense = null;

        int nErr = 0;
        IntPtr ptrErr = getErrorMsg(hHandle, ref nErr);
        string strError = System.Runtime.InteropServices.Marshal.PtrToStringAnsi(ptrErr, nErr);

        if (nRet != 0)
        {
            dynamic objDev = Newtonsoft.Json.JsonConvert.DeserializeObject(strDev);
            string strHDD = objDev.HDD;
            string strDomain = objDev.Domain;

            if (strError.Contains("Invalid"))
                Response.Write("<text>Your HDD Serial Key is " + strHDD + "<br />Your Domain is " + strDomain + "<br /><br />"
                    + strError + "</text>");
            else
                Response.Write("<text>" + strError + "</text>");

            return;
        }

        nRet = doRecognize(hHandle, imgBuf, imgBuf.Length);
        //imgBuf = null;

        int nSize = 0, nFace = 0, nCardImg = 0;
        IntPtr ptrFace = getFaceImage(hHandle, ref nFace);
        IntPtr ptrCard = getCardImage(hHandle, ref nCardImg);
        byte[] byFace = null;
        byte[] byCard = null;

        if (ptrFace != null && nFace > 0)
        {
            byFace = new byte[nFace];
            System.Runtime.InteropServices.Marshal.Copy(ptrFace, byFace, 0, nFace);
        }

        if (ptrCard != null && nCardImg > 0)
        {
            byCard = new byte[nCardImg];
            System.Runtime.InteropServices.Marshal.Copy(ptrCard, byCard, 0, nCardImg);
        }

        if (nRet <= 0)
        {
            Response.Write("<text>Failed to Recognize.</text>");
            /*if (ptrFace != null)
                Response.Write("<face>" + "data:image/jpg;base64," + Convert.ToBase64String(byFace) + "</face>");

            if (ptrCard != null)
                Response.Write("<card>" + "data:image/jpg;base64," + Convert.ToBase64String(byCard) + "</card>");

            byFace = null;
            byCard = null;

            if (ptrFace != null) System.Runtime.InteropServices.Marshal.FreeHGlobal(ptrFace);
            if (ptrCard != null) System.Runtime.InteropServices.Marshal.FreeHGlobal(ptrCard);*/
            int nResult = 0;
            IntPtr ptrface = doFaceDetect(hHandle, imgBuf, imgBuf.Length, ref nResult);

            byte[] byface1;
            if (ptrface != null)
            {
                if (nResult > 0)
                {
                    byface1 = new byte[nResult];
                    System.Runtime.InteropServices.Marshal.Copy(ptrface, byface1, 0, nResult);
                    Response.Write("<face>" + "data:image/jpg;base64," + Convert.ToBase64String(byface1) + "</face>");
                }
                else
                {
                    Response.Write("<face></face>");
                }
                if (imgBuf != null)
                    Response.Write("<card>" + "data:image/jpg;base64," + Convert.ToBase64String(imgBuf) + "</card>");

                byface1 = null;
                imgBuf = null;
                GC.Collect();
            }
            return;
        }

        IntPtr ptrRes = getResult(hHandle, ref nSize);
        string strResult = System.Runtime.InteropServices.Marshal.PtrToStringAnsi(ptrRes, nSize);

        strResult = strResult.Replace("\r\n", "<br />");
        strResult = strResult.Replace("\r", "<br />");
        strResult = strResult.Replace("\n", "<br />");

        dynamic objResult = Newtonsoft.Json.JsonConvert.DeserializeObject(strResult);
        string strParseText = ParseJsonObject(nCardType, objResult, nRet);
        string[] strList = strParseText.Split('\n');

        string strText = "";
        foreach (string item in strList)
        {
            if (item.Equals("")) continue;
            strText += HttpContext.Current.Server.HtmlEncode(item);
            strText += "<br />";
        }

        if (byFace != null)
            Response.Write("<face>" + "data:image/jpg;base64," + Convert.ToBase64String(byFace) + "</face>");
        //Response.Write("<text>" + strText + "<br />" + strError + "</text>");
        Response.Write("<text>" + strText + "</text>");
        if (byCard != null)
            Response.Write("<card>" + "data:image/jpg;base64," + Convert.ToBase64String(byCard) + "</card>");

        byFace = null;
        byCard = null;

        if (ptrFace != null) System.Runtime.InteropServices.Marshal.FreeHGlobal(ptrFace);
        if (ptrCard != null) System.Runtime.InteropServices.Marshal.FreeHGlobal(ptrCard);

        releaseCardEngine(hHandle);
        GC.Collect();
    }
    catch (Exception e)
    {
        message = e.Message;
        Response.Write("<text>" + message + "</text>");
    }
%>
