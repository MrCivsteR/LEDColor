using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using OpenLibSys;
using System.Windows.Controls;
using System.Windows;
using System.Net.NetworkInformation;
using System.Security.Cryptography.X509Certificates;

namespace LEDControl
{
    internal class Program
    {
        static void Main(string[] args)
        {
            if (args == null || args.Length == 0)
            {
                ReadColorInfo();
            }
            else
            {
                VerifyArgs(args);
            }
        }
        public static void VerifyArgs(string[] args)
        {
            if (!uint.TryParse(args[0], out uint joystick)) return;
            if (1 < joystick && joystick > 3) return;

            uint red = 0;
            uint green = 0;
            uint blue = 0;

            if (args.Length > 1) red = Clamp(args[1], 0, 255);
            if (args.Length > 2) green = Clamp(args[2], 0, 255);
            if (args.Length > 3) blue = Clamp(args[3], 0, 255);          

            uint[] color = {red, green, blue};

            SetJoyStick(joystick, color);
        }
        public static void ReadColorInfo()
        {
            string appDataFolder = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
            string filePath = Path.Combine(appDataFolder, "LEDColor\\ColorInfo.txt");

            if (!File.Exists(filePath)) return;

            var lines = File.ReadLines(filePath);

            foreach (var line in lines)
            {
                string[] args = line.Split(' ');
                VerifyArgs(args);
            }
        }
        public static void SetJoyStick(uint js, uint[] color)
        {
            Worker worker = new Worker();       
            worker.SetPixel(js, 1, color);
            worker.SetPixel(js, 2, color);
            worker.SetPixel(js, 3, color);
            worker.SetPixel(js, 4, color);
        }
        public static uint Clamp(string arg, uint min, uint max)
        {
            if (uint.TryParse(arg, out uint value))
            {
                return value < min ? min : value > max ? max : value;
            }
            else
            {
                return 0;
            }
            
        }
    }
}
