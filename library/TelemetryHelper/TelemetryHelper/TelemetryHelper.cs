
using System;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.Extensibility;
using System.Collections.Generic;
using System.Collections;
using Microsoft.ApplicationInsights.Channel;
using Microsoft.ApplicationInsights.DataContracts;
using System.Diagnostics;
using System.IO;
using System.Reflection;

namespace de.janhendrikpeters
{
    public class TelemetryHelper
    {
        private TelemetryClient telemetryClient = null;
        private static Assembly s_self;
        private static string s_dependencyFolder;
        private static HashSet<string> s_dependencies;
        private static AssemblyLoadContextProxy s_proxy;

        public string ApiConnectionString { get; private set; }
        public string ModuleName { get; set; }
        public bool StripPii { get; set; }

        public bool HasOptedIn
        {
            get
            {
                var psfOptIn = false;
                var optInVariable = "de.janhendrikpeters.telemetryoptin";
                if (PSFramework.Configuration.ConfigurationHost.Configurations.ContainsKey($"TelemetryHelper.{ModuleName}.OptIn"))
                {
                    try
                    {
                        psfOptIn = Convert.ToBoolean(PSFramework.Configuration.ConfigurationHost.Configurations[$"TelemetryHelper.{ModuleName}.OptIn"].Value);
                    }
                    catch
                    {
                        // Just suppress if no opt-in.
                    }
                }

                if (PSFramework.Configuration.ConfigurationHost.Configurations.ContainsKey($"TelemetryHelper.{ModuleName}.OptInVariable"))
                {
                    try
                    {
                        optInVariable = PSFramework.Configuration.ConfigurationHost.Configurations[$"TelemetryHelper.{ModuleName}.OptInVariable"].Value as string;
                    }
                    catch
                    {
                        // Just suppress if no opt-in.
                    }
                }

                return GetEnvironmentVariableAsBool(optInVariable, false) || psfOptIn;
            }
            private set { }
        }

        public TelemetryHelper()
        {
            Init();

            if (string.IsNullOrWhiteSpace(ApiConnectionString)) return;

            UpdateConnectionString(ApiConnectionString);
        }

        public TelemetryHelper(string moduleName)
        {
            Init();
            ModuleName = moduleName;

            if (PSFramework.Configuration.ConfigurationHost.Configurations.ContainsKey($"TelemetryHelper.{ModuleName}.ApplicationInsights.ConnectionString"))
            {
                ApiConnectionString = PSFramework.Configuration.ConfigurationHost.Configurations[$"TelemetryHelper.{ModuleName}.ApplicationInsights.ConnectionString"].Value as string;
            }

            if (PSFramework.Configuration.ConfigurationHost.Configurations.ContainsKey($"TelemetryHelper.{ModuleName}.StripPii"))
            {
                StripPii = Convert.ToBoolean(PSFramework.Configuration.ConfigurationHost.Configurations[$"TelemetryHelper.{ModuleName}.StripPii"].Value);
            }

            if (string.IsNullOrWhiteSpace(ApiConnectionString)) return;

            UpdateConnectionString(ApiConnectionString);

            if (StripPii)
            {
                telemetryClient.Context.Cloud.RoleInstance = "nope";
                telemetryClient.Context.Cloud.RoleName = "nope";
            }
        }

        private void Init()
        {
            StripPii = true;
            DisableHeartbeat();
            s_self = typeof(TelemetryHelper).Assembly;
            s_dependencyFolder = Path.GetDirectoryName(s_self.Location);
            s_dependencies = new(StringComparer.Ordinal);
            s_proxy = AssemblyLoadContextProxy.CreateLoadContext("telemetryhelper-load-context");

            foreach (string filePath in Directory.EnumerateFiles(s_dependencyFolder, "*.dll"))
            {
                s_dependencies.Add(AssemblyName.GetAssemblyName(filePath).FullName);
            }

            AppDomain.CurrentDomain.AssemblyResolve += ResolvingHandler;
        }

        public void UpdateConnectionString(string ConnectionString)
        {
            var config = TelemetryConfiguration.CreateDefault();
            config.ConnectionString = ConnectionString;
            config.TelemetryChannel.DeveloperMode = false;
            if (null == telemetryClient)
            {
                telemetryClient = new TelemetryClient(config);
            }

            ApiConnectionString = ConnectionString;
        }

        // taken from https://github.com/powershell/powershell
        private static bool GetEnvironmentVariableAsBool(string name, bool defaultValue)
        {
            var str = Environment.GetEnvironmentVariable(name);
            if (string.IsNullOrEmpty(str))
            {
                return defaultValue;
            }

            switch (str.ToLowerInvariant())
            {
                case "true":
                case "1":
                case "yes":
                    return true;
                case "false":
                case "0":
                case "no":
                    return false;
                default:
                    return defaultValue;
            }
        }

        public void SendMetric(string name, double value)
        {
            if (!HasOptedIn) return;

            Debug.Write($"User opted in, sending metric {name}, value {value}");

            var mi = telemetryClient.GetMetric(name);
            mi.TrackValue(value);
            Debug.Write("Metric tracked");
        }

        public void SendMetric(string name, string dimension1, double value)
        {
            if (!HasOptedIn) return;

            Debug.Write($"User opted in, sending metric {name}-{dimension1}, value {value}");

            var mi = telemetryClient.GetMetric(name, dimension1);
            mi.TrackValue(value);
            Debug.Write("Metric tracked");
        }

        public void SendMetric(string name, string dimension1, string dimension2, double value)
        {
            if (!HasOptedIn) return;

            Debug.Write($"User opted in, sending metric {name}-{dimension1}-{dimension2}, value {value}");

            var mi = telemetryClient.GetMetric(name, dimension1, dimension2);
            mi.TrackValue(value);
            Debug.Write("Metric tracked");
        }

        public void SendTrace(string message, SeverityLevel severityLevel = SeverityLevel.Information)
        {
            if (!HasOptedIn) return;

            Debug.Write($"User opted in, sending trace {message}, severity {severityLevel}");

            telemetryClient.TrackTrace(message, severityLevel);
            Debug.Write("Trace sent");
        }

        public void SendEvent(string eventName, Dictionary<string, string> properties = null, Dictionary<string, double> metrics = null)
        {
            if (!HasOptedIn) return;

            Debug.Write($"User opted in, sending event {eventName}");

            telemetryClient.TrackEvent(eventName, properties, metrics);
            Debug.Write("Event sent");
        }

        public void SendAvailability (string testName, DateTimeOffset timeStamp, TimeSpan duration, string location, bool success = true, string message = "", Dictionary<string, string> properties = null, Dictionary<string, double> metrics = null)
        {
            if (!HasOptedIn) return;

            Debug.Write($"User opted in, tracking availability for {testName}");
            telemetryClient.TrackAvailability(testName, timeStamp, duration, location, success, message, properties, metrics);
            Debug.Write("Availability sent");
        }

        public void Flush()
        {
            telemetryClient.Flush();
        }

        public void SendError(Exception exc)
        {
            if (!HasOptedIn) return;

            Debug.Write($"User opted in, sending exception");

            telemetryClient.TrackException(exc);
            Debug.Write("Event sent");
        }

        private void DisableHeartbeat()
        {
            var telemetryModules = Microsoft.ApplicationInsights.Extensibility.Implementation.TelemetryModules.Instance;

            foreach (var module in telemetryModules.Modules)
            {
                if (module is Microsoft.ApplicationInsights.Extensibility.Implementation.Tracing.IHeartbeatPropertyManager hbeatManager)
                {
                    var hb = module as Microsoft.ApplicationInsights.Extensibility.Implementation.Tracing.IHeartbeatPropertyManager;
                    hb.IsHeartbeatEnabled = false;
                }
            }
        }

        // Thank you, Dongbo Wang!  https://github.com/daxian-dbw/PowerShell-ALC-Samples 
        private static bool IsAssemblyMatching(AssemblyName assemblyName, Assembly requestingAssembly)
        {
            // The requesting assembly is always available in .NET, but could be null in .NET Framework.
            // - When the requesting assembly is available, we check whether the loading request came from this
            //   module, so as to make sure we only act on the request from this module.
            // - When the requesting assembly is not available, we just have to depend on the assembly name only.
            return requestingAssembly is not null
                ? requestingAssembly == s_self && s_dependencies.Contains(assemblyName.FullName)
                : s_dependencies.Contains(assemblyName.FullName);
        }

        internal static Assembly ResolvingHandler(object sender, ResolveEventArgs args)
        {
            var assemblyName = new AssemblyName(args.Name);
            if (IsAssemblyMatching(assemblyName, args.RequestingAssembly))
            {
                string fileName = assemblyName.Name + ".dll";
                string filePath = Path.Combine(Assembly.GetExecutingAssembly().Location, fileName);

                if (File.Exists(filePath))
                {
                    Console.WriteLine($"<*** Fall in 'ResolvingHandler': Newtonsoft.Json, Version=13.0.0.0  -- Loaded! ***>");
                    // - In .NET, load the assembly into the custom assembly load context.
                    // - In .NET Framework, assembly conflict is not a problem, so we load the assembly
                    //   by 'Assembly.LoadFrom', the same as what powershell.exe would do.
                    return s_proxy is not null
                        ? s_proxy.LoadFromAssemblyPath(filePath)
                        : Assembly.LoadFrom(filePath);
                }
            }

            return null;
        }
    }
}
