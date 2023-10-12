using OpenLibSys;
using System;
using System.Threading;

namespace LEDControl
{
    public class Worker
    {
        const uint EC_OBF = 0x01;  // Output Buffer Full
        const uint EC_IBF = 0x02;  // Input Buffer Full
        const uint EC_DATA = 0x62; // Data Port
        const uint EC_SC = 0x66;   // Status/Command Port
        const uint RD_EC = 0x80;   // Read Embedded Controller
        const uint WR_EC = 0x81;   // Write Embedded Controller

        private readonly Ols ols = new Ols();
        public void SetColor(uint js, uint[] color)
        {
            uint[] zones = new uint[]{1, 2, 3, 4};
            for (uint i = 0; i < 3; i++)
            {
                for (uint zone = 0; zone < 4; zone++)
                {
                    uint ZoneColor = zones[zone] * 3 + i;
                    uint Intensity = color[i] * 100 / 200;
                    SetLED(js, ZoneColor, Intensity);
                }
            }
        }
        public void SetLED(uint js, uint zone, uint brightness)
        {
            ECRAMWrite(0x6d, js);
            ECRAMWrite(0xb1, zone);
            ECRAMWrite(0xb2, brightness);
            ECRAMWrite(0xbf, 0x10);
            ECRAMWrite(0xbf, 0xff);
        }
        private void ECRAMWrite(uint address, uint data)
        {
            SendECCommand(WR_EC);
            SendECData(address);
            SendECData(data);
        }
        private void SendECCommand(uint command)
        {
            if (ECReady())
            {
                OlsWrite(EC_SC, command);
            }
        }
        private void SendECData(uint data)
        {
            if (ECReady())
            {
                OlsWrite(EC_DATA, data);
            }
        }
        private bool ECReady()
        {
            var timeout = DateTime.Now.Add(TimeSpan.FromMilliseconds(50));
            while (DateTime.Now < timeout && (OlsRead(EC_SC) & EC_IBF) != 0x0)
            {
                Thread.Sleep(1);
            }

            if (DateTime.Now <= timeout)
            {
                return true;
            }
            Console.WriteLine("EC not ready!");
            return false;
        }
        private void OlsWrite(uint port, uint value)
        {
            ols.WriteIoPortByte((ushort)port, (byte)value);
        }
        private uint OlsRead(uint port)
        {
            return ols.ReadIoPortByte((ushort)port);
        }
    }
}