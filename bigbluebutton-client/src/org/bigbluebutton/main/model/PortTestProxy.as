/**
* BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
* 
* Copyright (c) 2012 BigBlueButton Inc. and by respective authors (see below).
*
* This program is free software; you can redistribute it and/or modify it under the
* terms of the GNU Lesser General Public License as published by the Free Software
* Foundation; either version 3.0 of the License, or (at your option) any later
* version.
* 
* BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
* WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
* PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License along
* with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.
*
*/
package org.bigbluebutton.main.model {
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getClassLogger;
	import org.bigbluebutton.main.model.modules.ModulesDispatcher;

	public class PortTestProxy {
		private static const LOGGER:ILogger = getClassLogger(PortTestProxy);      
    
		private var nc:NetConnection;
		private var tunnel:Boolean;
		private var port:String;
		private var hostname:String;
		private var application:String;
		private var modulesDispatcher:ModulesDispatcher;
		
		public function PortTestProxy(modulesDispatcher: ModulesDispatcher) {
			this.modulesDispatcher = modulesDispatcher;
		}
		
		public function connect(tunnel:Boolean, hostname:String = "", port:String = "", application:String = "", testTimeout:Number = 10000):void {
      this.tunnel = tunnel;
			var portTest:PortTest = new PortTest(tunnel, hostname, port, application, testTimeout);
			portTest.addConnectionSuccessListener(connectionListener);

			portTest.connect();
		}
		
		private function connectionListener(status:String, tunnel:Boolean, hostname:String, port:String, application:String):void {
			if (status == "SUCCESS") {				
				modulesDispatcher.sendPortTestSuccessEvent(port, hostname, tunnel, application);			
			} else {
				modulesDispatcher.sendPortTestFailedEvent(port, hostname, tunnel, application);
			}				 		
		}
					
		public function close():void {	
			nc.removeEventListener(NetStatusEvent.NET_STATUS, netStatusEventHandler);
			nc.close();
		}
	
		protected function netStatusEventHandler(event:NetStatusEvent):void  {
			var info:Object = event.info;
			var statusCode : String = info.code;
			
			if (statusCode == "NetConnection.Connect.Success") {
				modulesDispatcher.sendPortTestSuccessEvent(port, hostname, tunnel, application);
			} else if (statusCode == "NetConnection.Connect.Rejected" ||
				 	  statusCode == "NetConnection.Connect.Failed" || 
				 	  statusCode == "NetConnection.Connect.Closed" ) {
				modulesDispatcher.sendPortTestFailedEvent(port, hostname, tunnel, application);
			} else {
        modulesDispatcher.sendPortTestFailedEvent(port, hostname, tunnel, application);
			}
			// Close NetConnection.
			close();
		}
		
		/**
		 * The Red5 oflaDemo returns bandwidth stats.
		 */		
		public function onBWDone() : void {	}
	}
}
