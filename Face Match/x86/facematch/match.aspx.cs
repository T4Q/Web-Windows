using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

namespace asp_facematch
{
    public struct SFace
    {
        public int X { get; set; }
        public int Y { get; set; }
        public int Width { get; set; }
        public int Height { get; set; }
        public short Yaw { get; set; }
        public short Pitch { get; set; }
        public short Roll { get; set; }
        public double Confidence { get; set; }
    }

    public class BitmapEx
    {
        int width = 0;
        int height = 0;
        int stride = 0;
        byte[] buffer;
        Bitmap bitmap;

        public Bitmap GetBitmap()
        {
            return bitmap;
        }
        public BitmapEx()
        {

        }
        public BitmapEx(Bitmap bmp)
        {
            LoadBitmap(bmp);
        }
        public BitmapEx(Stream stream)
        {
            LoadBitmap(stream);
        }

        public BitmapEx(String filename)
        {
            LoadBitmap(filename);
        }
        public BitmapEx(int width, int height, byte[] rgbbuff)
        {
            LoadBitmap(width, height, rgbbuff);
        }

        public int GetWidth()
        {
            return width;
        }

        public int GetHeight()
        {
            return height;
        }

        public int GetStride()
        {
            return stride;
        }

        public byte[] GetBuffer()
        {
            return buffer;
        }

        public string GetBase64JpegFormat()
        {
            //Bitmap rsbmp = ResizeBitmap(bitmap, 800, bitmap.Height * 800 / bitmap.Width);
            System.IO.MemoryStream ms = new MemoryStream();
            bitmap.Save(ms, ImageFormat.Jpeg);
            byte[] byteImage = ms.ToArray();
            string ret = Convert.ToBase64String(byteImage); // Get Base64
            return ret;
        }

        public Bitmap ResizeBitmap(Bitmap bmp, int width, int height)
        {
            Bitmap result = new Bitmap(width, height);
            using (Graphics g = Graphics.FromImage(result))
            {
                g.DrawImage(bmp, 0, 0, width, height);
            }

            return result;
        }

        public void RotateBitmap(int step)
        {
            //step : 1 - > 90 clockwise
            //step : 2 -> 180 clockwise
            //step : 3 -> 270 clockwise or 90 counterclockwise

            try
            {
                if (step == 1)
                {
                    bitmap.RotateFlip(System.Drawing.RotateFlipType.Rotate90FlipNone);
                    LoadBitmap(bitmap);
                }
                else if (step == 2)
                {
                    bitmap.RotateFlip(System.Drawing.RotateFlipType.Rotate90FlipNone);
                    LoadBitmap(bitmap);
                }
                else if (step == 3)
                {
                    bitmap.RotateFlip(System.Drawing.RotateFlipType.Rotate90FlipNone);
                    LoadBitmap(bitmap);
                }
            }
            catch (Exception e)
            {

            }
        }

        bool LoadBitmap(Bitmap bmp)
        {
            try
            {
                bitmap = bmp;
                width = bitmap.Width;
                height = bitmap.Height;
                if (width == 0 || height == 0)
                    return false;

                Rectangle rect = new Rectangle(0, 0, width, height);
                BitmapData bitmapData = bitmap.LockBits(rect, ImageLockMode.ReadOnly, PixelFormat.Format24bppRgb);
                stride = bitmapData.Stride;
                buffer = new byte[width * height * 3];
                for (int y = 0; y < height; y++)
                    System.Runtime.InteropServices.Marshal.Copy(bitmapData.Scan0 + y * stride, buffer, y * width * 3, width * 3);
                bitmap.UnlockBits(bitmapData);
            }
            catch (Exception e)
            {
                return false;
            }
            return true;
        }

        bool LoadBitmap(String filename)
        {
            try
            {
                return LoadBitmap(new Bitmap(filename));
            }
            catch (Exception e)
            {
                return false;
            }
        }

        bool LoadBitmap(Stream stream)
        {
            if (stream.Length == 0)
                return false;

            try
            {
                return LoadBitmap(new Bitmap(stream));
            }
            catch (Exception e)
            {
                return false;
            }
        }

        bool LoadBitmap(int width, int height, byte[] rgbbuff)
        {
            Bitmap bmp = new Bitmap(width, height, PixelFormat.Format24bppRgb);
            Rectangle rect = new Rectangle(0, 0, width, height);
            BitmapData bitmapData = bmp.LockBits(rect, ImageLockMode.ReadOnly, PixelFormat.Format24bppRgb);
            stride = bitmapData.Stride;
            for (int y = 0; y < height; y++)
                System.Runtime.InteropServices.Marshal.Copy(rgbbuff, y * width * 3, bitmapData.Scan0 + y * stride, width * 3);
            bmp.UnlockBits(bitmapData);
            return LoadBitmap(bmp);
        }

        public void SaveImage(String filename)
        {
            bitmap.Save(filename);
        }
    }

    public class MatchResponseResult
    {
        public string message { get; set; }
        public double score { get; set; }
        public int left1 { get; set; }
        public int top1 { get; set; }
        public int width1 { get; set; }
        public int height1 { get; set; }
        public int left2 { get; set; }
        public int top2 { get; set; }
        public int width2 { get; set; }
        public int height2 { get; set; }
        public int index { get; set; }

        public string retimg1 { get; set; }

        public string retimg2 { get; set; }

        public MatchResponseResult(int index)
        {
            this.score = 0;
            message = "0 %";
            this.left1 = 0;
            this.top1 = 0;
            this.width1 = 0;
            this.height1 = 0;
            this.left2 = 0;
            this.top2 = 0;
            this.width2 = 0;
            this.height2 = 0;
            this.retimg1 = "";
            this.retimg2 = "";
            this.index = index;
        }
    }

    public partial class match : System.Web.UI.Page
    {
        [DllImport(@"FaceEngine.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)]
        public static extern Int32 StartEngine(string path);

        [DllImport(@"FaceEngine.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern Int32 InitEngine();

        [DllImport(@"FaceEngine.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern Int32 CloseEngine();

        public static void DetectFaces(byte[] imgRGBBuff, Int32 dwWidth, Int32 dwHeight, ref Int32 pcount, ref SFace pfaces, float[] pFeatureBuf, byte[] imgOutBuff, ref Int32 pOutWidth, ref Int32 pOutHeight)
        {
            unsafe
            {
                SFace face = new SFace();
                SFace* pFace = &face;
                //                float[] pp = new float[256];
                DetectFace(imgRGBBuff, dwWidth, dwHeight, ref pcount, pFace, pFeatureBuf, imgOutBuff, ref pOutWidth, ref pOutHeight);
                pfaces.X = face.X;
                pfaces.Y = face.Y;
                pfaces.Width = face.Width;
                pfaces.Height = face.Height;
                pfaces.Confidence = face.Confidence;
            }

        }
        // 
        [DllImport(@"FaceEngine.dll", CallingConvention = CallingConvention.Cdecl)]
        private static extern unsafe Int32 DetectFace(byte[] pImgRGBBuff, int iWidth, int iHeight, ref Int32 pcount, SFace* pfaces, float[] pFeatureBuf, byte[] pImgOutBuff, ref Int32 pOutWidth, ref Int32 pOutHeight);
        // 
        //         [DllImport(@"FaceEngine.dll", CallingConvention = CallingConvention.Cdecl)]
        //         public static extern Int32 GetExtractValues(byte[] pImgRGBBuff, int iWidth, int iHeight, int[] pFaceRect, float[] landmarks, byte[] pFeature);
        // 
        [DllImport(@"FaceEngine.dll", CallingConvention = CallingConvention.Cdecl)]
        public static extern double GetSimilarity(float[] pFeatureBuf1, float[] pFeatureBuf2);

        protected void Page_Load(object sender, EventArgs e)
        {
            StartEngine(AppDomain.CurrentDomain.BaseDirectory);
        }
    }
}