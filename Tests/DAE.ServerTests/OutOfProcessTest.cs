﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NUnit.Framework;
using Alphora.Dataphor.DAE.Server;
using Alphora.Dataphor.DAE.ServerTests.Utilities;
using System.Diagnostics;
using Alphora.Dataphor.Windows;
using System.IO;
using Alphora.Dataphor.DAE.Client;
using System.Threading;
using Alphora.Dataphor.DAE.Runtime.Data;

namespace Alphora.Dataphor.DAE.ServerTests
{
	[TestFixture]
	public class OutOfProcessTest
	{
		private ServerConfigurationManager FConfigurationManager;
		private ServerConfiguration FConfiguration;
		private Process FProcess;
		private DataSession FDataSession;

		[TestFixtureSetUp]
		public void FixtureSetup()
		{
			InstanceManager.Load();

			FConfigurationManager = new SQLCEServerConfigurationManager();
			FConfiguration = FConfigurationManager.GetTestConfiguration("TestOOPInstance");
			
			if (InstanceManager.Instances.HasInstance("TestOOPInstance"))
				InstanceManager.Instances.Remove("TestOOPInstance");
			
			InstanceManager.Instances.Add("TestOOPInstance", FConfiguration);
			InstanceManager.Save();
			
			ProcessStartInfo LProcessStartInfo = new ProcessStartInfo();
			LProcessStartInfo.FileName = Path.Combine(Path.GetDirectoryName(PathUtility.GetInstallationDirectory()), "Dataphor\\bin\\DAEServer.exe");
			LProcessStartInfo.WorkingDirectory = Path.GetDirectoryName(LProcessStartInfo.FileName);
			LProcessStartInfo.Arguments = "-n \"TestOOPInstance\"";
			LProcessStartInfo.UseShellExecute = false;
			LProcessStartInfo.RedirectStandardInput = true;
			FProcess = Process.Start(LProcessStartInfo);
			
			// TODO: This should be a wait for the process, but WaitForInputIdle only works on GUI apps
			Thread.Sleep(10000);
			
			ConnectionAlias LAlias = new ConnectionAlias();
			LAlias.Name = "TestOOPInstanceConnection";
			LAlias.InstanceName = "TestOOPInstance";
			
			FDataSession = new DataSession();
			FDataSession.Alias = LAlias;
			FDataSession.Open();
		}
		
		[TestFixtureTearDown]
		public void FixtureTearDown()
		{
			// Close the data session
			FDataSession.Close();
			
			// Send to stop the server
			FProcess.StandardInput.WriteLine();
			
			// Wait for the process
			FProcess.WaitForExit(30000);
			
			if (!FProcess.HasExited)
				FProcess.Kill();
				
			// Wait a little bit longer
			FProcess.WaitForExit(5000);
			
			// Try to reset the instance
			FConfigurationManager.ResetInstance();
		}
		
		[Test]
		public void TestCLI()
		{
			IServerProcess LProcess = FDataSession.ServerSession.StartProcess(new ProcessInfo(FDataSession.SessionInfo));
			try
			{
				var LFetchCount = FDataSession.ServerSession.SessionInfo.FetchCount;
				LProcess.Execute("create table Test { ID : Integer, key { ID } };", null);
				LProcess.Execute(String.Format("for var LIndex := 1 to {0} do insert row {{ LIndex ID }} into Test;", LFetchCount.ToString()), null);
				
				IServerCursor LCursor = LProcess.OpenCursor("select Test order by { ID } capabilities { navigable, backwardsnavigable, bookmarkable, searchable, updateable }", null);
				try
				{
					var LCounter = 0;
					while (LCursor.Next())
					{
						using (Row LRow = LCursor.Select())
						{
							LCounter += (int)LRow[0];
						}
					}
					
					if (LCounter != (LFetchCount * (LFetchCount + 1)) / 2)
						throw new Exception("Fetch count summation failed");
						
					LCursor.Reset();
					LCounter = 0;

					while (LCursor.Next())
					{
						using (Row LRow = LCursor.Select())
						{
							LCounter++;
							if (LCounter != (int)LRow[0])
								throw new Exception("Select failed");
						}
					}
					
					LCursor.Reset();
					LCounter = 0;
					
					LCursor.Next();
					LCursor.Next();
					
					using (Row LRow = LCursor.Select())
					{
						LRow[0] = -1;
						LCursor.Update(LRow);
					}
					
					using (Row LRow = LCursor.Select())
					{
						if ((int)LRow[0] != -1)
							throw new Exception("Update failed");
					}
					
					LCursor.Delete();
					
					using (Row LRow = LCursor.Select())
					{
						if ((int)LRow[0] != 1)
							throw new Exception("Delete failed");
							
						LRow[0] = 2;
						LCursor.Insert(LRow);
					}
					
					using (Row LRow = LCursor.Select())
					{
						if ((int)LRow[0] != 2)
							throw new Exception("Insert failed");
					}
					
					LCursor.Reset();
					LCounter = 0;
					Guid LBookmark = Guid.Empty;
					
					while (LCursor.Next())
					{
						using (Row LRow = LCursor.Select())
						{
							LCounter++;
							if (LCounter == 5)
								LBookmark = LCursor.GetBookmark();
						}
					}
					
					if (!LCursor.GotoBookmark(LBookmark, true))
						throw new Exception("GotoBookmark failed");
						
					using (Row LRow = LCursor.Select())
					{
						if ((int)LRow[0] != 5)
							throw new Exception("GotoBookmark failed");
					}
					
					LCursor.DisposeBookmark(LBookmark);
				}
				finally
				{
					LProcess.CloseCursor(LCursor);
				}

				LProcess.Execute("delete Test;", null);
				LFetchCount *= 10;
				LProcess.Execute(String.Format("for var LIndex := 1 to {0} do insert row {{ LIndex ID }} into Test;", LFetchCount.ToString()), null);
				
				LCursor = LProcess.OpenCursor("select Test order by { ID } capabilities { navigable, backwardsnavigable, bookmarkable, searchable, updateable }", null);
				try
				{
					var LCounter = 0;
					while (LCursor.Next())
					{
						using (Row LRow = LCursor.Select())
						{
							LCounter += (int)LRow[0];
						}
					}
					
					if (LCounter != (LFetchCount * (LFetchCount + 1)) / 2)
						throw new Exception("Fetch count summation failed");
						
					LCursor.Reset();
					LCounter = 0;

					while (LCursor.Next())
					{
						using (Row LRow = LCursor.Select())
						{
							LCounter++;
							if (LCounter != (int)LRow[0])
								throw new Exception("Select failed");
						}
					}
				}
				finally
				{
					LProcess.CloseCursor(LCursor);
				}
			}
			finally
			{
				FDataSession.ServerSession.StopProcess(LProcess);
			}
		}
		
		[Test]
		public void TestDataView()
		{
			FDataSession.Execute("create table TestForDataView { ID : Integer, Name : String, key { ID } };");
			FDataSession.Execute("insert row { 1 ID, 'Joe' Name } into TestForDataView;");

			DataView LDataView = FDataSession.OpenDataView("TestForDataView");
			try
			{
				LDataView.UseApplicationTransactions = false;
				if (!LDataView.IsEmpty())
				{
					LDataView.First();
					LDataView.Edit();
					LDataView["Name"].AsString = "John";
					LDataView.Refresh();
				}
			}
			finally
			{
				LDataView.Dispose();
			}
		}
	}
}