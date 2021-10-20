﻿using chocolatey;
using chocolatey.infrastructure.logging;
using System;
using System.Diagnostics;
using System.Reflection;
using System.Security.Principal;

namespace install_chocolatey
{
    class Program
    {
        static void Main(string[] args)
        {
            // If not running with elevated privileges, try to acquire them
            var identity = WindowsIdentity.GetCurrent();
            var principal = new WindowsPrincipal(identity);
            if (!principal.IsInRole(WindowsBuiltInRole.Administrator))
            {
                Process p = new Process();
                p.StartInfo.FileName = Assembly.GetExecutingAssembly().Location;
                p.StartInfo.Verb = "runas"; // elevated privileges
                p.StartInfo.UseShellExecute = true;
                try
                {
                    p.Start();
                    return;
                }
                catch
                {
                    Console.WriteLine("Error: must be run as administrator");
                }
            }
            else
            {
                // Set this environment variable to a sensible default value, otherwise chocolatey.lib will use the executable location
                if (string.IsNullOrEmpty(Environment.GetEnvironmentVariable("ChocolateyInstall")))
                    Environment.SetEnvironmentVariable("ChocolateyInstall", @"C:\ProgramData\chocolatey");

                var choco = Lets.GetChocolatey();
                choco.SetCustomLogging(new NullLog());

                choco.Set(conf => conf.CommandName = "upgrade");
                choco.RunConsole(new string[] { "-y", "--force", "chocolatey" });
                choco.RunConsole(new string[] { "-y", "--force", "chocolatey-gui" });

                Console.Write("\n\nSetup was successful. Press any key to quit.\n");
            }

            Console.ReadKey();
        }
    }
}
