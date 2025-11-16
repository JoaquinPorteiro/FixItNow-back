import { Controller, Get, Post, Body, Patch, Param, UseGuards } from '@nestjs/common';
import { BookingsService } from './bookings.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { UpdateBookingStatusDto } from './dto/update-booking-status.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { GetUser } from '../auth/decorators/get-user.decorator';
import { UserRole } from '@prisma/client';

@Controller('bookings')
@UseGuards(JwtAuthGuard)
export class BookingsController {
  constructor(private readonly bookingsService: BookingsService) {}

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.CONSUMER)
  create(@GetUser('id') userId: string, @Body() createBookingDto: CreateBookingDto) {
    return this.bookingsService.create(userId, createBookingDto);
  }

  @Get()
  findAll(@GetUser('id') userId: string, @GetUser('role') userRole: UserRole) {
    return this.bookingsService.findAll(userId, userRole);
  }

  @Get(':id')
  findOne(@Param('id') id: string, @GetUser('id') userId: string, @GetUser('role') userRole: UserRole) {
    return this.bookingsService.findOne(id, userId, userRole);
  }

  @Patch(':id/status')
  updateStatus(
    @Param('id') id: string,
    @GetUser('id') userId: string,
    @GetUser('role') userRole: UserRole,
    @Body() updateStatusDto: UpdateBookingStatusDto,
  ) {
    return this.bookingsService.updateStatus(id, userId, userRole, updateStatusDto);
  }
}
