using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Text;

namespace de.janhendrikpeters
{
    internal class AssemblyLoadContextProxy
    {
        private readonly object CustomContext;
        private readonly MethodInfo loadFromAssemblyPathMethod;

        private AssemblyLoadContextProxy(Type alc, string loadContextName)
        {
            var ctor = alc.GetConstructor(new[] { typeof(string), typeof(bool) });
            loadFromAssemblyPathMethod = alc.GetMethod("LoadFromAssemblyPath", new[] { typeof(string) });
            CustomContext = ctor.Invoke(new object[] { loadContextName, false });
        }

        internal Assembly LoadFromAssemblyPath(string assemblyPath)
        {
            return (Assembly)loadFromAssemblyPathMethod.Invoke(CustomContext, new[] { assemblyPath });
        }

        internal static AssemblyLoadContextProxy CreateLoadContext(string name)
        {
            if (string.IsNullOrEmpty(name))
            {
                throw new ArgumentNullException(nameof(name));
            }

            var alc = typeof(object).Assembly.GetType("System.Runtime.Loader.AssemblyLoadContext");
            return alc != null
                ? new AssemblyLoadContextProxy(alc, name)
                : null;
        }
    }
}
