using chocolatey;
using chocolatey.infrastructure.logging;
using System;
using System.Diagnostics;
using System.Reflection;
using System.Security.Principal;

namespace bootstrapper
{
    class Program
    {
        static void Main(string[] args)
        {
            // If not running with elevated privileges, try to acquire them
            if (!IsAdministrator())
            {
                RelaunchAsAdministrator();
                return;
            }

            // Set this environment variable to a sensible default value, otherwise chocolatey.lib will use the executable location
            if (string.IsNullOrEmpty(Environment.GetEnvironmentVariable("ChocolateyInstall")))
                Environment.SetEnvironmentVariable("ChocolateyInstall", @"C:\ProgramData\chocolatey");

            var choco = Lets.GetChocolatey();
            choco.SetCustomLogging(new NullLog());

            choco.Set(conf => conf.CommandName = "upgrade");
            choco.RunConsole(new string[] { "-y", "--force", "chocolatey" });
            choco.Set(conf => conf.CommandName = "upgrade");
            choco.RunConsole(new string[] { "-y", "--force", "chocolateygui" });
        }

        static bool IsAdministrator()
        {
            var identity = WindowsIdentity.GetCurrent();
            var principal = new WindowsPrincipal(identity);
            return principal.IsInRole(WindowsBuiltInRole.Administrator);
        }

        static void RelaunchAsAdministrator()
        {
            Process p = new Process();
            p.StartInfo.FileName = Assembly.GetExecutingAssembly().Location;
            p.StartInfo.Verb = "runas"; // elevated privileges
            p.StartInfo.UseShellExecute = true;
            try
            {
                p.Start();
            }
            catch
            {
                Console.WriteLine("Error: must be run as administrator");
            }
        }
    }
}
