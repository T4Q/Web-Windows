using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Http;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
using System.Text;

namespace cardrec
{
    public partial class proc : System.Web.UI.Page
    {
        [DllImport("cardocr.dll", EntryPoint = "initCardEngine", CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr initCardEngine(int nCardType);

        [DllImport("cardocr.dll", EntryPoint = "loadDB", CallingConvention = CallingConvention.Cdecl)]
        public static extern int loadDB(IntPtr hHandle, byte[] szDic, int nDic, byte[] szDic1, int nDic1, 
            byte[] tData, int ntData, byte[] license, int nlicense);

        [DllImport("cardocr.dll", EntryPoint = "doRecognize", CallingConvention = CallingConvention.Cdecl)]
        public static extern int doRecognize(IntPtr hHandle, byte[] szImage, int nLen);

        [DllImport("cardocr.dll", EntryPoint = "getResult", CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr getResult(IntPtr hHandle, ref int nLen);

        [DllImport("cardocr.dll", EntryPoint = "getFaceImage", CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr getFaceImage(IntPtr hHandle, ref int nLen);

        [DllImport("cardocr.dll", EntryPoint = "doFaceDetect", CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr doFaceDetect(IntPtr hHandle, byte[] szImage, int nLen, ref int nSize);

        [DllImport("cardocr.dll", EntryPoint = "getCardImage", CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr getCardImage(IntPtr hHandle, ref int nLen);

        [DllImport("cardocr.dll", EntryPoint = "getErrorMsg", CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr getErrorMsg(IntPtr hHandle, ref int nLen);

        [DllImport("cardocr.dll", EntryPoint = "getDevInfo", CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr getDevInfo(IntPtr hHandle, ref int nLen);

        [DllImport("cardocr.dll", EntryPoint = "releaseCardEngine", CallingConvention = CallingConvention.Cdecl)]
        public static extern void releaseCardEngine(IntPtr hHandle);

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected byte[] GetBMPFromBitmap(System.Drawing.Bitmap bmp)
        {
            byte[] byteAry = new byte[0];
            using (System.IO.MemoryStream stream = new System.IO.MemoryStream())
            {
                bmp.Save(stream, System.Drawing.Imaging.ImageFormat.Bmp);
                byteAry = stream.ToArray();
                stream.Close();
            }
            return byteAry;
        }

        protected string ParseJsonObject(int nCardType, dynamic jsonObj, int nRet)
        {
            string strRet = "";
            if (nCardType == 0) //PAN
                strRet = ParsePanCard(jsonObj);
            else if (nCardType == 1) //AADHAR 
                strRet = ParseAadharCard(jsonObj);
            else if (nCardType == 2) //MRZ
                strRet = ParseMrzCard(jsonObj, nRet);

            return strRet;
        }

        private string ParsePanCard(dynamic jsonObj)
        {
            string cardtype = jsonObj.Card;
            string name = jsonObj.Name;
            string fathername = jsonObj.FatherName;
            string birthday = jsonObj.Birthday;
            string pan = jsonObj.PAN;

            string result = "Card : " + cardtype + "\n";
            result += "Name : " + name + "\n";
            result += "Second Name : " + fathername + "\n";
            result += "BOB : " + birthday + "\n";
            result += "PAN Card No. : " + pan;

            return result.Replace("<br />", "\n");
        }

        private string ParseAadharCard(dynamic jsonObj)
        {
            string cardtype = jsonObj.Card;
            if (cardtype.Contains("front")) //front
            {
                string name = jsonObj.Name;
                string birthday = jsonObj.Birth;
                string sex = jsonObj.Sex;
                string ann = jsonObj.AAN;

                string result = "Card : " + cardtype + "\n";
                result += "Name : " + name + "\n";
                result += "DOB : " + birthday + "\n";
                result += "Sex : " + sex + "\n";
                result += "Aadhar Card No. : " + ann;

                return result.Replace("<br />", "\n");
            }
            else if (cardtype.Contains("back"))
            {
                string address = jsonObj.Address;

                string result = "Card : " + cardtype + "\n";
                result += address;

                return result.Replace("<br />", "\n");
            }

            return "";
        }

        private string ParseMrzCard(dynamic jsonObj, int nRet)
        {
            string strRet = "";

            string lines = jsonObj.Lines;
            string doctype = jsonObj.DocType;
            string country = jsonObj.Country; ;
            string surname = jsonObj.Surname;
            string givenname = jsonObj.Givename;
            string docnumber = jsonObj.DocNumber; //Passport Number
            string docchecksum = jsonObj.CheckNumber; //Check Number
            string nationality = jsonObj.Nationality;
            string birth = jsonObj.Birth;
            string birthchecksum = jsonObj.BirthCheckNumber;//Birth Check Number
            string sex = jsonObj.Sex;
            string expirationdate = jsonObj.ExpirationDate; //Expiration Date
            string expirationchecksum = jsonObj.ExpirationCheckNumber; //Expiration Check Number
            string otherid = jsonObj.PersonalNumber; //Personal Number
            string otheridchecksum = jsonObj.PersonalNumberCheck; //Personal Number Check
            string secondrowchecksum = jsonObj.SecondRowCheckNumber; //SecondRow Check Number

            if (nRet > 1)
                strRet = "Incorrect Document \n";
            else if (nRet == 1)
                strRet = "Correct Document \n";

            strRet += "MRZ : " + lines + "\n";
            strRet += "Document Type : " + doctype + "\n";
            strRet += "Country : " + country + "\n";
            strRet += "Surname : " + surname + "\n";
            strRet += "Given Names : " + givenname + "\n";
            strRet += "Document No. : " + docnumber + "\n";
            strRet += "Document CheckNumber : " + docchecksum + "\n";
            strRet += "Nationality : " + nationality + "\n";
            strRet += "Birth : " + birth + "\n";
            strRet += "BirthCheckNumber : " + birthchecksum + "\n";
            strRet += "Sex : " + sex + "\n";
            strRet += "ExpirationDate : " + expirationdate + "\n";
            strRet += "ExpirationCheckNumber : " + expirationchecksum + "\n";
            //if (otherid.Length > 0)
            strRet += "Other ID : " + otherid + "\n";
            strRet += "Other ID Check : " + otheridchecksum + "\n";
            strRet += "SecondRowCheckNumber : " + secondrowchecksum + "\n";
            strRet += "Flag : " + nRet.ToString() + "\n";

            strRet = strRet.Replace("<br />", "\n");
            return strRet;
        }
    }
}