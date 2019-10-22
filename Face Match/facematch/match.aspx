<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="match.aspx.cs" Inherits="asp_facematch.match" %>

<%
    string message = "";
    try
    {
        string faceImg1 = Request.Form.Get("imgLeft");
        string faceImg2 = Request.Form.Get("imgRight");
        int index = Convert.ToInt32(Request.Form.Get("index"));
        asp_facematch.MatchResponseResult ret = new asp_facematch.MatchResponseResult(index);

        System.IO.Stream stream1 = null;
        if (faceImg1 != null)
        {
            if (faceImg1.Length > 0)
            {
                byte[] img = Convert.FromBase64String(faceImg1);
                System.IO.MemoryStream memStream = new System.IO.MemoryStream();
                memStream.Write(img, 0, img.Length);
                memStream.Flush();
                memStream.Seek(0, System.IO.SeekOrigin.Begin);
                stream1 = memStream;
            }
        }
        asp_facematch.BitmapEx bmp1 = null;
        if (stream1 != null)
        {
            bmp1 = new asp_facematch.BitmapEx(stream1);
        }

        System.IO.Stream stream2 = null;
        if (faceImg2 != null)
        {
            if (faceImg2.Length > 0)
            {
                byte[] img = Convert.FromBase64String(faceImg2);
                System.IO.MemoryStream memStream = new System.IO.MemoryStream();
                memStream.Write(img, 0, img.Length);
                memStream.Flush();
                memStream.Seek(0, System.IO.SeekOrigin.Begin);
                stream2 = memStream;
            }
        }

        asp_facematch.BitmapEx bmp2 = null;
        if (stream2 != null)
        {
            bmp2 = new asp_facematch.BitmapEx(stream2);
        }

        float[] pFeature1 = null;
        float[] pFeature2 = null;

        string license = HttpContext.Current.Server.MapPath("~/db/accuraface.license");

        if (!System.IO.File.Exists(license))
        {
            Response.Write("<text>Could not find file './db/accuraface.license' <br /> License Key Missing</text>");
            return;
        }
        System.IO.Stream license_is = OpenFile(license);
        byte[] bylicense = new byte[license_is.Length];
        license_is.Read(bylicense, 0, (int)license_is.Length);
        license_is.Close();

        int aaa = InitEngine();
        if (bmp1 != null)
        {
            if (bmp1.GetWidth() > 0)
            {
                asp_facematch.SFace face1 = new asp_facematch.SFace();
                int count1 = 0, i = 1;
                pFeature1 = new float[128];
                int outWidth = bmp1.GetWidth();
                int outHeight = bmp1.GetHeight();
                byte[] outImg = new byte[outWidth * outHeight * 3];
                DetectFaces(bmp1.GetBuffer(), bmp1.GetWidth(), bmp1.GetHeight(), ref count1, ref face1, pFeature1, outImg, ref outWidth, ref outHeight);

                if (count1 == 0) pFeature1 = null;

                asp_facematch.BitmapEx outBmp = new asp_facematch.BitmapEx(outWidth, outHeight, outImg);
                ret.left1 = face1.X;
                ret.top1 = face1.Y;
                ret.width1 = face1.Width;
                ret.height1 = face1.Height;
                ret.retimg1 = "data:image/jpg;base64," + outBmp.GetBase64JpegFormat();
            }

        }
        if (bmp2 != null)
        {
            if (bmp2.GetWidth() > 0)
            {
                asp_facematch.SFace face2 = new asp_facematch.SFace();
                int count2 = 0, i = 1;
                pFeature2 = new float[128];
                int outWidth = bmp2.GetWidth();
                int outHeight = bmp2.GetHeight();
                byte[] outImg = new byte[outWidth * outHeight * 3];
                DetectFaces(bmp2.GetBuffer(), bmp2.GetWidth(), bmp2.GetHeight(), ref count2, ref face2, pFeature2, outImg, ref outWidth, ref outHeight);
                if (count2 == 0) pFeature2 = null;

                asp_facematch.BitmapEx outBmp = new asp_facematch.BitmapEx(outWidth, outHeight, outImg);
                ret.left2 = face2.X;
                ret.top2 = face2.Y;
                ret.width2 = face2.Width;
                ret.height2 = face2.Height;
                ret.retimg2 = "data:image/jpg;base64," + outBmp.GetBase64JpegFormat();
            }
        }
        if (pFeature1 != null && pFeature2 != null)
        {
            double score = GetSimilarity(pFeature1, pFeature2);
            ret.score = score * 100;
            if (ret.score > 47 && ret.score < 70) ret.score += 19.5;
            else if (ret.score >= 70 && ret.score < 80) ret.score += 10.5;
            if (ret.score > 100) ret.score = 100;
            ret.message = ret.score.ToString("F1", System.Globalization.CultureInfo.InvariantCulture) + " %";
        }
        CloseEngine();

        string strRet = Newtonsoft.Json.JsonConvert.SerializeObject(ret);
        Response.Write(strRet);
    }
    catch (Exception e)
    {
        //message = e.Message;
        //Response.Write("<text>" + message + "</text>");
    }
%>
