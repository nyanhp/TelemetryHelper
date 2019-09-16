
using System;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.Extensibility;
using System.Collections.Generic;
using System.Collections;
using Microsoft.ApplicationInsights.Channel;
using Microsoft.ApplicationInsights.DataContracts;
using System.Diagnostics;

namespace de.janhendrikpeters
{
    public class TelemetryHelper
    {
        private TelemetryClient telemetryClient = null;

        public string ApiInstrumentationKey { get; private set; }
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
            StripPii = true;
            DisableHeartbeat();

            if (string.IsNullOrWhiteSpace(ApiInstrumentationKey)) return;

            UpdateInstrumentationKey(ApiInstrumentationKey);
        }

        public TelemetryHelper(string moduleName)
        {
            StripPii = true;
            ModuleName = moduleName;
            DisableHeartbeat();

            if (PSFramework.Configuration.ConfigurationHost.Configurations.ContainsKey($"TelemetryHelper.{ModuleName}.ApplicationInsights.InstrumentationKey"))
            {
                ApiInstrumentationKey = PSFramework.Configuration.ConfigurationHost.Configurations[$"TelemetryHelper.{ModuleName}.ApplicationInsights.InstrumentationKey"].Value as string;
            }

            if (PSFramework.Configuration.ConfigurationHost.Configurations.ContainsKey($"TelemetryHelper.{ModuleName}.StripPii"))
            {
                StripPii = Convert.ToBoolean(PSFramework.Configuration.ConfigurationHost.Configurations[$"TelemetryHelper.{ModuleName}.StripPii"].Value);
            }

            if (string.IsNullOrWhiteSpace(ApiInstrumentationKey)) return;

            UpdateInstrumentationKey(ApiInstrumentationKey);

            if (StripPii)
            {
                telemetryClient.Context.Cloud.RoleInstance = "nope";
                telemetryClient.Context.Cloud.RoleName = "nope";
            }
        }

        public void UpdateInstrumentationKey(string instrumentationKey)
        {
            if (null == telemetryClient)
            {
                telemetryClient = new TelemetryClient();
            }

            TelemetryConfiguration.Active.InstrumentationKey = instrumentationKey;
            TelemetryConfiguration.Active.TelemetryChannel.DeveloperMode = false;
            ApiInstrumentationKey = instrumentationKey;
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
    }
}
