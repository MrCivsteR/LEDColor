using OpenLibSys;
using System;
using System.Data.OleDb;
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

        public void SetPixel(uint js, uint position, uint[] color)
        {
            if (ols.GetStatus() != (uint)Ols.Status.NO_ERROR) return;
            if (ols.GetDllStatus() != (uint)Ols.OlsDllStatus.OLS_DLL_NO_ERROR) return;
            
            ECCommand(js, position * 3, color[0]);
            ECCommand(js, position * 3 + 1, color[1]);
            ECCommand(js, position * 3 + 2, color[2]);
        }

        private void ECCommand(uint command, uint parameter1, uint parameter2)
        {
            ECRAMWrite(0x6d, command);
            ECRAMWrite(0xb1, parameter1);
            ECRAMWrite(0xb2, parameter2);
            ECRAMWrite(0xbf, 0x10);
            Thread.Sleep(10);
            ECRAMWrite(0xbf, 0xff);
            Thread.Sleep(10);
        }

        public void ECRAMDone()
        {
            ECRAMWrite(0xbf, 0x10);
            Thread.Sleep(10);
            ECRAMWrite(0xbf, 0xff);
            Thread.Sleep(10);
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